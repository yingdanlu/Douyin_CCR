#!/usr/bin/env python
# coding: utf-8

import face_recognition
import cv2
import os
import glob
import csv
import pandas as pd
import numpy as np
from PIL import Image, ImageStat
from scipy.interpolate import interp1d
import webcolors
import subprocess
import time


# Function for calculating frame-level color complexity
def entropy(frame):
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    signal = gray[0:gray.shape[0],0:gray.shape[1]].flatten()
    lensig=signal.size
    symset=list(set(signal))
    numsym=len(symset)
    propab=[np.size(signal[signal==i])/(1.0*lensig) for i in symset]
    ent=np.sum([p*np.log2(1.0/p) for p in propab])
    return ent


# Find the dominant color in rgb values
def fast_unique_count_app(frame):
    frame = frame.reshape(-1, 3).astype(int)
    frame = frame[:,0] * 1e6 + frame[:,1] * 1e3 + frame[:,2]
    colors, count = np.unique(frame, return_counts=True)
    res = colors[count.argmax()]
    R, res = divmod(res, 1e6)
    G, B = divmod(res, 1e3)
    return np.array([R, G, B]).astype(np.uint8)

# Find the closest colour if the color is not with basic color names
def closest_colour(requested_colour):
    min_colours = {}
    for key, name in webcolors.CSS21_HEX_TO_NAMES.items():
        r_c, g_c, b_c = webcolors.hex_to_rgb(key)
        rd = (r_c - requested_colour[0]) ** 2
        gd = (g_c - requested_colour[1]) ** 2
        bd = (b_c - requested_colour[2]) ** 2
        min_colours[(rd + gd + bd)] = name
    return min_colours[min(min_colours.keys())]

# Turn the color from hex into name
def get_colour_name(requested_colour):
    try:
        closest_name = webcolors.rgb_to_name(requested_colour)
    except ValueError:
        closest_name = closest_colour(requested_colour)
    return closest_name

# Find the dominant color in names
def get_dominant_color(frame):
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    requested_colour = fast_unique_count_app(frame)
    closest_name = get_colour_name(requested_colour)
    return closest_name


# Full function to extract frame-level features and calculate video-level features
def feature_extract(video, frames_per_slice = 6):
    # Open video file
    video_capture = cv2.VideoCapture(video)
    frames = []
    frame_count = 0
    face_count = 0
    luminance = []
    entropy_store = []
    dominant_color = []
    frame_numbers = 0
    face_count_binary = 0

    while video_capture.isOpened():
        # Read every single frame of video
        ret, frame = video_capture.read()
        if not ret:
            print("Can't receive frame (stream end?). Exiting ...")
            break
        if ret == True:
            if frame_count % frames_per_slice == 0:
                # Convert the image from BGR color (which OpenCV uses) to LAB colorspace for luminance extraction
                lab = cv2.cvtColor(frame, cv2.COLOR_BGR2LAB)
                luminance.append(lab[...,0].mean())
                entropy_store.append(entropy(frame))
                dominant_color.append(get_dominant_color(frame))
                # Convert the image from BGR color (which OpenCV uses) to RGB color (which face_recognition uses)
                frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                # Do face recognition through the face_recognition API
                faces = face_recognition.face_locations(frame)
                # Count faces in each frame
                face_count += len(faces)
                if len(faces) > 0:
                    # Binary indicator of whether a frame contains any faces
                    face_count_binary += 1
            frame_count += 1
    # Compute the rate of frames dominated by any warm colors
    warmth = (dominant_color.count('red') + dominant_color.count('orange')+ 
                  dominant_color.count('yellow')+ dominant_color.count('maroon') + 
                  dominant_color.count('olive'))/ len(luminance)    
    # Compute the rate of frames dominated by any cold colors
    cold = (dominant_color.count('green') + dominant_color.count('blue')+ 
                  dominant_color.count('aqua')+ dominant_color.count('navy') + 
                  dominant_color.count('teal'))/ len(luminance)    
    # Return the output
    return [str(video.split('.mp4')[0]), frame_count, len(luminance), np.mean(luminance), 
            np.median(luminance), np.mean(entropy_store), np.median(entropy_store), face_count_binary,
           warmth, cold] 

def main():
# Start a csv to store the results
    a=open('videos_sample_outputs.csv','w',1)
    w=csv.writer(a)
    fieldnames=['video_id', 'frame_numbers', 'frame_numbers_sampled','luminance_avg','luminance_med', 'entropy_avg', 
                'entropy_med', 'face_binary', 'warmth', 'cold']
    w.writerow(fieldnames)

    # Redirect to the video folder
    os.chdir("./videos_sample/")
    extension = 'mp4'
    all_filenames = [i for i in glob.glob('*.{}'.format(extension))]
    all_filenames = sorted(all_filenames)

    # Computation
    for video_id in all_filenames:
        try:
            print(video_id)
            features = feature_extract(video_id)
            w.writerow(features)
            print("==============Feature extraction Done=============")
        except: 
            # In case any video is truncated
            print("problematic %s" % video_id.split('.mp4')[0])
            continue

if __name__ == "__main__":
    main()