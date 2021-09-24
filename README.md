# Repo Readme

Replication files for *The Pervasive Presence of Chinese GovernmentContent on Douyin Trending Videos* (R&R, *Computational Communication Research*)

### Three steps to facilitate the analysis. 

Step 1: We collected metadata and video data of the Douyin Trending videos, and all data used for this study are stored in *CCR_final_nc.csv*

Step 2: For video data, we extract visual features through the code *feature_final.py*. We also provided five videos to test on the code.

Step 3: Using all metadata and results from visual analysis, we created all figures and tables through *CCR_RR_nc.R*.

### Variable descriptions:
Variables from the metadata
<br />video_id: id of the videos
<br />create_date: creation date of the video
<br />create_time: creation time of the video
<br />duration: video length
<br />topic_name: topic that the video is attached
<br />uid: id of the user
<br />account_type: type of the account (combined regime accounts and official media accounts)
<br />newspaper_ch: Chinese name of the newspaper
<br />daily: whether a state media account is a daily newspaper
<br />account_type2: type of the account with new coding rules
<br />topic_category: category of the topic
<br />covid: whether a topic is related to covid-19

Variables from the visual analysis
<br />frame_numbers: total number of frames contained in a video
<br />frame_numbers_sampled: total number of frames used for analysis
<br />luminance_avg: video brightness
<br />entropy_avg: video color complexity
<br />face_binary: number of frames containing faces
<br />warmth: warm color dominance score
<br />cold: cold color dominance score
<br />face_rate: face presence

