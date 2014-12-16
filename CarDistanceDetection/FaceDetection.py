ESC_KEY = 27

import cv2
import serial
import time

vc = cv2.VideoCapture(0)

count = 0

if vc.isOpened():
   print "vc is open!!"
   # vc.read query the video camera and saves the image in frame.
   # Return_value has the information of weather the read was a success or not
   return_value, frame = vc.read()

k = -1

ser = serial.Serial('/dev/ttyACM0', 9600)

face_cascade = cv2.CascadeClassifier("haarcascades/haarcascade_frontalface_default.xml")

def process_image(img):
   global count

   faces = face_cascade.detectMultiScale(img, 1.3, 4, cv2.cv.CV_HAAR_SCALE_IMAGE, (75,75))

   if len(faces) > 0:
      print "Found a face"

      ser.write('1')

      ser.flushInput()
   
   else: 
      print "No Face"
      ser.write('0')

      ser.flushInput()

   #time.sleep(0.25)

if __name__ == "__main__":

   count = 0

   #while True:

      #print count

      #ser.write('1')

      #ser.flushInput()

      #count += 1

   while vc.isOpened():
      ret, img = vc.read()  # get a frame from the video card
      img = cv2.pyrDown(img)

      if ret and (img is not None):
         process_image(img)
