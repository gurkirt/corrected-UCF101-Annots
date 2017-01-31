# Spatio-Temporal Annotations of 24 classes of UCF101 dataset

### Introduction
Bounding box annotations of humans for 24 action classes of <a href="http://crcv.ucf.edu/data/UCF101.php">UCF101 dataset</a> 
is available at the download page of <a href="http://www.thumos.info/download.html">THUMOS dataset</a> in xml format. 
Parsing these annotation is not as easy, which resulted in different result of 
everyone working on spatio-temporal localisation of action on these 24 classes.

We gather three parsed version above available annotations.
<ol>
<li> Saha <it>et. al.</it> [1] provide parsed annotations in <code>.mat format</code> and are available <a href"https://bitbucket.org/sahasuman/bmvc2016_code">here</a>. 
These annotation were used by [1,4,5] in their works.
We keep it in this repository under filename <code>annotV5.mat</code></li> 
<li> We asked Weinzaepfel <it>et. al.</it>[2] for annotations used in [2] and initial version of [4]. Current version of [4] uses annotations provided by [1]. 
We keep these annotation under filename<code>annot_full_phillipe.mat</code></li>
<li> Gemert <it>et. al.</it> [3] provided theirs version of parsed annotations <a href="<https://github.com/jvgemert/apt">apt</a><li>. It is kept under filename <code>annot_apt.mat</code>
</ol>

<p>There are various problem and advantages in these parsed version when compared to each other. 
For instance, Saha's version has most number of action instances but temporal labelling and consistency between different action instances is problem. 
Gemert's version very much similar. 
Weinzaepfel's version doesn't pick up all the action instances, some videos doesn't even have one action instance, 
but bounding-boxes accuracy temporal labelling accuracy are slightly better than other version.
Parsing original was going to lead to similar problems.</p>

### Correction

<p> So, I went through the pain to look through the annotations of each video. 
I found that around 600 videos annotations of Saha's had some problems and 300 had decent annotations for those videos in either in Weinzaepfel's version or Gemert's version.
Finally, rest required more intelligent combination of three versions. At the the end, we ended up with 3195 videos with good annotations in filename <code>finalAnnots.mat</code>. 
We had to remove 9 videos for which we couldn't manage re-annotation, 3 were test videos and 6 train videos. There may be 5-10 videos which still might have some error in annotations.</p>

### Performance Numbers
<p>We have evaluated the approach of [1] and [5] and report the performance of their approaches on older annotations from [1] 
and new corrected annotations annotations. These results are produced on 911 test videos of split 1.</p>

Below is the table using older annotations from [1]

<table style="width:100%">
  <tr>
    <th>IoU Threshold = </th>
    <th>0.2</th> 
    <th>0.5</th>
    <th>0.5</th>
    <th>0.5:0.95</th>
  </tr>
  <tr>
    <th>Saha et al [1]</th> 
    <th>67.89</th>
    <th>36.87</th> 
    <th>06.78</th>
    <th>14.29</th>
  </tr>
  <tr>
    <th>Singh et al [5]</th> 
    <th>69.12</th>
    <th>41.16</th> 
    <th>10.31</th>
    <th>17.19</th>
  </tr>
  <tr>
    <th>Singh et al [5]</th> 
    <th>70.73</th>
    <th>43.20</th> 
    <th>10.43</th>
    <th>18.02</th>
  </tr>
</table>


Below is the table using new corrected annotations.

<table style="width:100%">
  <tr>
    <th>IoU Threshold = </th>
    <th>0.2</th> 
    <th>0.5</th>
    <th>0.5</th>
    <th>0.5:0.95</th>
  </tr>
  <tr>
    <th>Saha et al [1]</th> 
    <th>66.06</th>
    <th>36.19</th> 
    <th>07.83</th>
    <th>14.30</th>
  </tr>
  <tr>
    <th>Singh et al [5]</th> 
    <th>67.34</th>
    <th>39.61</th> 
    <th>11.04</th>
    <th>17.14</th>
  </tr>
  <tr>
    <th>Singh et al [5]</th> 
    <th>68.90</th>
    <th>42.04</th>
    <th>11.48</th> 
    <th>18.07</th>
    
  </tr>
</table>


If you want to regenrate those number please download results of [1] and [5] form [here](https://drive.google.com/drive/folders/0B-LzM05qEdk0dTRuY0xNUXlPMG8?usp=sharing). 
Then create 'results' folder in root dirctory of this repo and place all (3) donwloed files.
Now, you can rund <code>comput_mAPs.m</code> form inside the *evaluation* folder.

<h3>References:</h3>
<ol>
<li> S. Saha, G. Singh, M. Sapienza, P. H. S. Torr, and F. Cuzzolin, Deep learning for detecting multiple space-time action tubes in videos. In British Machine Vision Conference, 2016</li>
<li> P. Weinzaepfel, Z. Harchaoui, and C. Schmid, Learning to track for spatio-temporal action localization. In IEEE Int. Conf. on Computer Vision and Pattern Recognition, June 2015 </li>
<li> J. C. van Gemert, M. Jain, E. Gati, and C. G. Snoek. Apt: Action localization proposals from dense trajectories. In BMVC, volume 2, page 4, 2015.</li>
<li> X. Peng and C. Schmid. Multi-region two-stream R-CNN for action detection. In ECCV 2016 - European Conference on Computer Vision, Amsterdam, Netherlands, Oct. 2016.</li>
<li> G. Singh, S Saha, M. Sapienza, P. H. S. Torr and F Cuzzolin. "Online Real time Multiple Spatiotemporal Action Localisation and Prediction on a Single Platform." arXiv preprint arXiv:1611.08563 (2016).</li>
<ol>
