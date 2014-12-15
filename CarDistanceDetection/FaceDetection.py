ESC_KEY = 27

import cv2
import serial
import time

vc = cv2.VideoCapture(0)

if vc.isOpened():
    print "vc is open!!"
    # vc.read query the video camera and saves the image in frame.
    # Return_value has the information of weather the read was a success or not
    return_value, frame = vc.read()

k = -1

ser = serial.Serial('/dev/ttyACM0', 9600)

face_cascade = cv2.CascadeClassifier("haarcascades/haarcascade_frontalface_default.xml")

def process_image(img):
    #gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(img, 1.3, 4, cv2.cv.CV_HAAR_SCALE_IMAGE, (10,10))

    if len(faces) > 0:
        #print "Found a face"
        ser.write('1')

    else:
	#print "No Face"
	ser.write('0')

    time.sleep(0.1)
    #for (x,y,w,h) in faces:
    #   cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)

while vc.isOpened():
    ret, img = vc.read()  # get a frame from the video card
    img = cv2.pyrDown(img)
    img = cv2.pyrDown(img)

    if ret and (img is not None):
       process_image(img)

    #cv2.imshow('input', img)

    # get possible text input from the open figures
    # if a user presses a key, it will show up here
    k = cv2.waitKey(10)
    #if k == ESC_KEY:
    #    break
