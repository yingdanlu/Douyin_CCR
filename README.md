## Repo Readme

# This repo contains:

1) Raw video data to dataset processing: 5 sample video files so that *feature_final.py* can be run to produce the first eight columns of *CCR_final_nc_visual.csv* (for our paper, we ran *feature_final.py* on all video files to generate the video-related features of *CCR_final_nc.csv*; all other columns of *CCR_final_nc.csv* were directly obtained in the data gathering process or based on human coding).

2) Replication files: replication data, *CCR_final_nc.csv*, and code, *CCR_RR_nc.R*, to produce all figures and tables in *The Pervasive Presence of Chinese Government Content on Douyin Trending Videos* (*Computational Communication Research*)

# Variable descriptions:
<ins>Variables from metadata</ins>
<br />video_id: id of the videos
<br />create_date: creation date of the video
<br />create_time: creation time of the video
<br />duration: video length
<br />topic_name: trending topic that the video relates to
<br />uid: id of the user

<ins>Variables extraced from videos</ins>
<br />frame_numbers: total number of frames contained in a video
<br />frame_numbers_sampled: total number of frames used for analysis
<br />luminance_avg: video brightness
<br />entropy_avg: video color complexity
<br />face_binary: number of frames containing faces
<br />warmth: warm color dominance score
<br />cold: cold color dominance score
<br />face_rate: proportion of frames that contain faces

<ins>Variables from human coding</ins>
<br />account_type: type of the account
<br />account_type2: type of the account (combines gov/ccp and state media accounts into regime-affiliated accounts)
<br />newspaper_ch: Chinese name of all newspaper accounts
<br />daily: whether newspapers is a daily (日报), which means it is a mouthpiece newspaper
<br />topic_category: category of the trending topic
<br />covid: whether a topic relates to covid-19


