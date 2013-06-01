#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'matrix'

# Compatibility-mode
#require 'ffi'
#module FFI::Library
  #alias :attach_function_without_blocking :attach_function

  #def attach_function(name, func, args, returns = nil, options = nil)
    #options ||= {}
    #options[:blocking] = true
    #attach_function_without_blocking(name, func, args, returns, options)
  #end

#end

GC.disable
# /Compatibility-mode

require 'phidgets-ffi'


class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

# TODO: Maybe create a Matrix3x3 class?
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end

  def normalize
    ret = m3x3
    0.upto(2) do |i|
      length = Math.sqrt(self[i, 0] * self[i, 0] + self[i, 1] * self[i, 1] + self[i, 2] * self[i, 2])
      if length == 0.0
        ret[i, 0] = 0
        ret[i, 1] = 0
        ret[i, 2] = 0
      else
        ret[i, 0] = self[i, 0] / length
        ret[i, 1] = self[i, 1] / length
        ret[i, 2] = self[i, 2] / length
      end
    end

    ret
  end
end

# TODO: Clean this up, and maybe create a V3 class?
class Vector
  def x; self.send :[], 0; end
  def y; self.send :[], 1; end
  def z; self.send :[], 2; end
  def x=(v); self.send :[]=, 0, v; end
  def y=(v); self.send :[]=, 1, v; end
  def z=(v); self.send :[]=, 2, v; end

  def v3_length
    Math.sqrt(x * x + y * y + z * z)
  end

  def v3_crossproduct(vB)
    cross = v3(0,0,0)
    cross.x = y * vB.z - z * vB.y
    cross.y = z * vB.x - x * vB.z
    cross.z = x * vB.y - y * vB.x
    cross
  end

  def v3_dotproduct(vB)
    x * vB.x + y * vB.y + z * vB.z
  end
end

def v3(x, y, z)
  Vector[x,y,z]
end

def m3x3
 Matrix.build(3,3){0}
end

def getRotationMatrix(from1, to1)
  from = from1.normalize
  to = to1.normalize

  vs = from.v3_crossproduct( to ) # axis multiplied by sin
  v = vs.normalize # axis of rotation
  c = from.v3_dotproduct to # cos angle
  vc = v * (1.0 - c) # axis multiplied by (1-cos angle)
 
  # I'm pretty sure I'm doing this right... 
  vc.x = vc.x * v.y
  vc.z = vc.z * v.x
  vc.y = vc.y * v.z
  vp = v3( vc.x, vc.z, vc.y ) # some cross multiplies

  rotM = m3x3
  rotM[0, 0] = vc.x * v.x + c; rotM[1, 0] = vp.x - vs.z;    rotM[2, 0] = vp.y + vs.y;
  rotM[0, 1] = vp.x + vs.z;    rotM[1, 1] = vc.y * v.y + c; rotM[2, 1] = vp.z - vs.x;
  rotM[0, 2] = vp.y - vs.y;    rotM[1, 2] = vp.z + vs.x;    rotM[2, 2] = vc.z * v.z + c;

  rotM.normalize
end

def nextRotMatrix(rotMatrix, rotations)
  # assuming C(t2) = C(t1)A(t1) where A(t1) is the rotation matrix relating the body frame between time t1 and t2 (I + B)
  # A(t1) = [  1  y  z ]  for small angles (<180 degrees). x, y and z are rotations about the axes
  #         [ -y  1  x ]
  #         [ -z -x  1 ]

  mA = m3x3

  mA[0, 0] = 1;             mA[1, 0] = rotations.y;   mA[2, 0] = rotations.z;
  mA[0, 1] = -rotations.y;  mA[1, 1] = 1;             mA[2, 1] = rotations.x;
  mA[0, 2] = -rotations.z;  mA[1, 2] = -rotations.z;  mA[2, 2] = 1;

  # Normalized to keep the vectors unit length
  (rotMatrix * mA).normalize
end

#computes a rotation matrix based on a previous rotation matrix and a series of angle rotations
#better algorithm then nextRotMatrix - still need to keep rotation < 180 degrees
#This uses the rectangular rule
def nextRotMatrix2(rotMatrix, rotations)
  #This uses C2 = C1( I + (sin(w)/w)B + ((1 - cos(w))/w)B^2 )
  #where w is the total rotation, I is the identity matrix and B is the scew symmetric form of the rotation vector

  mI = m3x3
  
  mI[0, 0] = 1; mI[1, 0] = 0; mI[2, 0] = 0;
  mI[0, 1] = 0; mI[1, 1] = 1; mI[2, 1] = 0;
  mI[0, 2] = 0; mI[1, 2] = 0; mI[2, 2] = 1;

  mB = m3x3
  mB[0, 0] = 0;             mB[1, 0] = -rotations.z;  mB[2, 0] = rotations.y;
  mB[0, 1] = rotations.z;   mB[1, 1] = 0;             mB[2, 1] = -rotations.x;
  mB[0, 2] = -rotations.y;  mB[1, 2] = rotations.x;   mB[2, 2] = 0;

  totalRotation = rotations.v3_length

  smallRot = m3x3

  # Don't divide by 0
  if (totalRotation > 0)
    smallRot = ( mI + ((Math.sin(totalRotation) / totalRotation) * mB)) + 
      # NOTE: I'm not sure If I'm screwing up this value due to the order of operations:
      mB * mB * (1 - Math.cos(totalRotation) / (totalRotation * totalRotation))
  else
    smallRot = mI
  end

  newRotMatrix = rotMatrix * smallRot

  # If these are off, it's because of slight errors - these are no longer Rotation matrices, strictly speaking
  # The determinant should be 1
  # double det = Matrix3x3.Determinant(newRotMatrix)
  # This should give an Identity matrix
  # Matrix3x3 I = Matrix3x3.Multiply(Matrix3x3.Transpose(newRotMatrix), newRotMatrix);

  # Normalize to the the vectors Unit length
  newRotMatrix.normalize

  # Phiget NOTE: We should really be doing an orthonormalization
end

# public static void RotatePoints(Matrix3x3 rotMatrix, Vector3[] bodyFramePoints, Vector3[] referenceFramePoints)
def rotatePoints(rotMatrix, referenceFramePoints)
  referenceFramePoints.collect{ |refFrame| refFrame * rotMatrix }
end

class SpatialSensor
  attr_accessor :rotMatrix

  G = 9.80665

  # This was initially a checkbox in the GUI
  INITIAL_ROT_WITH_GRAVITY = true

  def initialize
    @lastMsCount = 0
    @lastMsCountGood = false
    @rotMatrix = m3x3
    @magTemp = v3 0,0,0
    @timer = Time.now
    @milliseconds2 = 0
    @magRef = v3 0,0,0
    @doMag = false
    @velocities = v3 0, 0, 0
    @gravityRef = v3 0, 1, 0
    @positions = v3 0, 0, 0
    @zeroing = false
    @magSamplesTaken = 0
    @gravitySamplesTaken = 0
    @gravitySamples = 100
    @gravityTemp = v3 0, 0, 0
    @overRotCount = 0
  end

  def phid_tick(data)
    if @zeroing
      if data.compass_axes.length > 0
        @magTemp.x += data.compass_axes[0].magnetic_field
        @magTemp.y += data.compass_axes[2].magnetic_field
        @magTemp.z -= data.compass_axes[1].magnetic_field
        @magSamplesTaken = @magSamplesTaken + 1
      end

      @gravityTemp.x += data.accelerometer_axes[0].acceleration
      @gravityTemp.y += data.accelerometer_axes[2].acceleration
      @gravityTemp.z -= data.accelerometer_axes[1].acceleration
      @gravitySamplesTaken = @gravitySamplesTaken + 1

      if @gravitySamplesTaken >= @gravitySamples
        @gravityTemp.x = @gravityTemp.x / @gravitySamplesTaken
        @gravityTemp.y = @gravityTemp.y / @gravitySamplesTaken
        @gravityTemp.z = @gravityTemp.z / @gravitySamplesTaken
        @gravityRef = @gravityTemp

        @gravityTemp = v3 0, 0, 0
        @gravitySamplesTaken = 0

        @magTemp.x /= @magSamplesTaken;
        @magTemp.y /= @magSamplesTaken;
        @magTemp.z /= @magSamplesTaken;
        @magRef = v3 @magTemp.x, @magTemp.y, @magTemp.z

        @magTemp = v3(0, 0, 0)
        @magSamplesTaken = 0

        @zeroing = false;
        finishZeroing
      end
    else
      if @lastMsCountGood
        timechange = Time.new.to_ms - @lastMsCount;
        timeChangeSeconds = timechange / 1000.0;

        calculateAttitude(data, timeChangeSeconds)
        calculatePosition(data, timeChangeSeconds)
      end
    end

    @lastMsCount = Time.now.to_ms
    @lastMsCountGood = true;
  end

  def zeroGyro(phid)
    phid.zero_gyro()

    # Do we care here?
    # Thread.Sleep(50);
    sleep 1

    @positions.x = 0
    @positions.y = 0
    @positions.z = 0

    @velocities.x = 0
    @velocities.y = 0
    @velocities.z = 0

    @overRotCount = 0

    @doMag = false

    @magTemp = v3 0,0,0 
    @magSamplesTaken = 0

    @gravitySamplesTaken = 0
    @gravityTemp = v3 0,0,0
    @zeroing = true
  end

  def finishZeroing
    # align body rotation matrix with reference frame
    rotMatrix = m3x3

    if INITIAL_ROT_WITH_GRAVITY
      # base the initial rotation matrix on the gravity measurement - keep the y axis (up-down) rotated so the cord is facing out
      # Calculate the angles and make sure they are -1 <= x <= 1

      # get a normalized version of the gravity vector to find angles
      gravityTemp = @gravityRef.normalize

      xAngle = Math.asin -@gravityTemp.x
      zAngle = Math.asin @gravityTemp.z

      # The board is up-side down
      if (@gravityRef.y > 0)
        xAngle = -xAngle
        zAngle = -zAngle
      end

      xRotMatrix = m3x3
      xRotMatrix[0, 0] = Math.cos(xAngle); xRotMatrix[1, 0] = -1 * Math.sin(xAngle); xRotMatrix[2, 0] = 0;
      xRotMatrix[0, 1] = Math.sin(xAngle); xRotMatrix[1, 1] = Math.cos(xAngle); xRotMatrix[2, 1] = 0;
      xRotMatrix[0, 2] = 0; xRotMatrix[1, 2] = 0; xRotMatrix[2, 2] = 1;

      # no rotation
      yRotMatrix = m3x3
      yRotMatrix[0, 0] = 1; yRotMatrix[1, 0] = 0; yRotMatrix[2, 0] = 0;
      yRotMatrix[0, 1] = 0; yRotMatrix[1, 1] = 1; yRotMatrix[2, 1] = 0;
      yRotMatrix[0, 2] = 0; yRotMatrix[1, 2] = 0; yRotMatrix[2, 2] = 1;

      zRotMatrix = m3x3
      zRotMatrix[0, 0] = 1; zRotMatrix[1, 0] = 0; zRotMatrix[2, 0] = 0;
      zRotMatrix[0, 1] = 0; zRotMatrix[1, 1] = Math.cos(zAngle); zRotMatrix[2, 1] = -1 * Math.sin(zAngle);
      zRotMatrix[0, 2] = 0; zRotMatrix[1, 2] = Math.sin(zAngle); zRotMatrix[2, 2] = Math.cos(zAngle);

      rotMatrix = xRotMatrix * yRotMatrix * zRotMatrix

      # The board is up-side down
      if (@gravityRef.y < 0)
        rotMatrix = rotMatrix * -1
      end

      # now rotate gravity into reference frame
      @gravityRef = rotMatrix * @gravityRef

      @magRef = rotMatrix * @magRef
    else
      # Assume initial rotation is flat
      rotMatrix[0, 0] = 1; rotMatrix[1, 0] = 0; rotMatrix[2, 0] = 0;
      rotMatrix[0, 1] = 0; rotMatrix[1, 1] = 1; rotMatrix[2, 1] = 0;
      rotMatrix[0, 2] = 0; rotMatrix[1, 2] = 0; rotMatrix[2, 2] = 1;
    end

    timer = Time.now
    @milliseconds = 0;
    @milliseconds2 = 0;

    @rotMatrix = rotMatrix;

    # TODO: Do we need this? I don't think we do
    # p.vertexBuffer = rotatePoints @rotMatrix, p.originalVertices
  end

  def calculateAttitude(data, timeChangeSeconds)
    rots = v3 0,0,0

    # TODO: Debug/Flag for overotation 
    #spatial.gyro_axes.each do |angRate|
      # if ((angRate >= phid.gyroAxes[0].AngularRateMax) || (angRate <= phid.gyroAxes[0].AngularRateMin))
    #end

    rots.x = -(timeChangeSeconds * data.gyro_axes[0].angular_rate * Math::PI / 180)
    rots.y = -(timeChangeSeconds * data.gyro_axes[2].angular_rate * Math::PI / 180)
    rots.z = (timeChangeSeconds * data.gyro_axes[1].angular_rate * Math::PI / 180)

    nextRotMatrix = nextRotMatrix2 @rotMatrix, rots
   
    passed = @timer - Time.now

    # accumulate magnetic data
    if data.compass_axes.length > 0
      @magTemp.x += data.compass_axes[0].magnetic_field
      @magTemp.y += data.compass_axes[1].magnetic_field
      @magTemp.z -= data.compass_axes[2].magnetic_field
      @magSamplesTaken += 1

      if (passed > @milliseconds2 + 100)
        @milliseconds2 = passed.to_ms

        # convert vector in reference frame to body frame
        expectedMag = @magRef * nextRotMatrix.transpose

        # actual magnetic vector
        @magTemp.x = @magTemp.x / @magSamplesTaken
        @magTemp.y = @magTemp.y / @magSamplesTaken;
        @magTemp.z = @magTemp.z / @magSamplesTaken;

        @magSamplesTaken = 0;

        if @doMag
          # find the angles between the two magnetic vectors. This gives a rotation matrix
          magRot = getRotationMatrix @magTemp, expectedMag

          # If these are off, its because of slight errors - these are no longer Rotation matrices, strictly speaking
          # The determinant should be 1
          det = magRot.determinant

          # This should give an Identity matrix
          magRot_identity = magRot.transpose * magRot

          magTempRot = @magTemp * magRot

          magDiff = @magTemp.normalize - expectedMag.normalize

          # TODO: Do we really need to do this here in this way?
          #if (compassCorrections.Checked)
          #{
              #nextRotMatrix = Matrix3x3.Normalize(Matrix3x3.Multiply(Matrix3x3.Normalize(nextRotMatrix), Matrix3x3.Normalize(magRot)));
          #}
        end

        @magTemp.x = 0
        @magTemp.y = 0
        @magTemp.z = 0
        @doMag = true
      end

    end

    @rotMatrix = nextRotMatrix
  end

  def calculatePosition(data, timeChangeSeconds)

    accelForcesBody = v3( data.accelerometer_axes[0].acceleration, 
      data.accelerometer_axes[2].acceleration, 
      -1 * data.accelerometer_axes[1].acceleration )

    accelForcesRef =  @rotMatrix * accelForcesBody

    accelForcesRefWithoutGravity = accelForcesRef - @gravityRef

    # convert from g's to m/s^2 - also, X is backwards
    accelForcesRefWithoutGravity.x = accelForcesRefWithoutGravity.x * G
    accelForcesRefWithoutGravity.y = -1 * accelForcesRefWithoutGravity.y * G
    accelForcesRefWithoutGravity.z = accelForcesRefWithoutGravity.z * G

    # Integrate accelerations into velocities in m/s: v2 = v1 + at
    @velocities.x += timeChangeSeconds * accelForcesRefWithoutGravity.x
    @velocities.y += timeChangeSeconds * accelForcesRefWithoutGravity.y
    @velocities.z += timeChangeSeconds * accelForcesRefWithoutGravity.z

    # Integrate velocities into positions in m: s2 = s1 + v2t
    @positions.x += timeChangeSeconds * @velocities.x
    @positions.y += timeChangeSeconds * @velocities.y
    @positions.z += timeChangeSeconds * @velocities.z

  end
end


ev_spatial = {}
ev_spatial_extents = {}
ev_spatial_attributes = {}

puts "Library Version: #{Phidgets::FFI.library_version}"

Phidgets::Log.enable :verbose
spatial = Phidgets::Spatial.new

ON_ATTACH = Proc.new do |device, obj|
  puts "Device attributes: #{device.attributes} attached"
end

ON_ERROR = Proc.new do |device, obj, code, description|
  puts "Error #{code}: #{description}"
end

ON_DETACH = Proc.new do |device, obj|
	puts "#{device.attributes.inspect} detached"
end

spatial.on_attach &ON_ATTACH
spatial.on_error  &ON_ERROR
spatial.on_detach &ON_DETACH 

sleep 2

# This might belong in attach
usable_spatial = SpatialSensor.new
usable_spatial.zeroGyro spatial

i = 0
ON_SPATIAL_DATA = Proc.new do |device, acceleration, magnetic_field, angular_rate, obj|
  begin

    ev_spatial_extents ||= {
      :acceleration_max => spatial.accelerometer_axes[0].acceleration_max, 
      :acceleration_max => spatial.accelerometer_axes[0].acceleration_max, 
      :acceleration_min => spatial.accelerometer_axes[0].acceleration_min,
      :gyroscope_max => spatial.gyro_axes[0].angular_rate_max,
      :gyroscope_min => spatial.gyro_axes[0].angular_rate_min,
      :compass_max => spatial.compass_axes[0].magnetic_field_max,
      :compass_min => spatial.compass_axes[0].magnetic_field_min
    }

    ev_spatial_attributes ||= spatial.attributes.to_hash.dup

    i+=1
    puts "#{i} Accel: #{acceleration.inspect} Mag: #{magnetic_field.inspect} Ang: #{angular_rate.inspect}" if i % 20 == 0

    usable_spatial.phid_tick(spatial)

    ev_spatial = {
      :acceleration => acceleration, 
      :gyroscope    => angular_rate,
      :compass      => magnetic_field ,
      :orientation  => usable_spatial.rotMatrix.to_a
    }
    sleep 0.005 # Seems like omiting this might crash ruby. Might be an OSX thing...  (Might need tuning...)
  rescue Phidgets::Error::UnknownVal
  rescue Exception => e
    puts "ERROR" + e.inspect
  end
end

spatial.on_spatial_data &ON_SPATIAL_DATA 

# We'll use this to block the execution. Phidget seems to run as an 'interrupt' 
# to this proc:
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get spatial_attributes'
        ret[:spatial_attributes] = ev_spatial_attributes
      when 'get spatial_extents'
        ret[:spatial_extents] = ev_spatial_extents
      when 'get spatial_data'
        ret[:spatial_data] = ev_spatial.dup
    end
    ws.send ret.to_json
  end
end
