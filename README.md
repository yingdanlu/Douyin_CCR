## Repo Readme
# Github repo for <i>The Pervasive Presence of Chinese Government Content on Douyin Trending Videos< /i>
# This repo contains:

1) Raw video data to dataset processing: 4 example video files so that *feature_final.py* can be run to produce *CCR_final_nc_visual.csv* (for our paper, we ran *feature_final.py* on all video files to generate the video-related features of *CCR_final_nc_new.csv*; all other columns of *CCR_final_nc_new.csv* were directly obtained in the data gathering process or based on human coding).

2) Replication files: replication data, *CCR_final_nc_new.csv*, and code, *CCR_RR_nc.R*, to produce all figures and tables in *The Pervasive Presence of Chinese Government Content on Douyin Trending Videos* (*Computational Communication Research*)

# Variable descriptions:
<ins>Variables from metadata</ins>
<br />create_date: creation date of the video
<br />create_time: creation time of the video
<br />duration: video length
<br />topic_name: trending topic that the video relates to
<br />account_hash: hashed id of the account

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
<br />regime_acct_type: further disaggregates regime-affiliated accounts
<br />topic_category: category of the trending topic
<br />covid: whether a topic relates to covid-19


