# SpatioTemporal Annotations of 24 for Classes of UCF101

### Introduction
Bounding box annotations of humans for 24 action classes of <a href="http://crcv.ucf.edu/data/UCF101.php">UCF101 dataset</a> 
is available at the download page of <a href="http://www.thumos.info/download.html">THUMOS dataset</a> in xml format. 
Parsing these annotation is not as easy, which resulted in different result of 
everyone working on spatio-temporal localisation of action on these 24 classes.

We gather three parsed version of above available annotations.
<ol>
<li> Saha <it>et. al.</it> [1] provide parsed annotations in <code>.mat format</code> and are available <a href"https://bitbucket.org/sahasuman/bmvc2016_code">here</a>. 
These annotation were used by [1,4,5] in their works.
We keep it in this repository under filename <code>annotV5.mat</code></li> 
<li> We asked Weinzaepfel <it>et. al.</it>[2] for annotations, which were used in [2] and initial version of [4]. Current version of [4] uses annotations provided by [1]. 
We keep these annotation under filename<code>annot_full_phillipe.mat</code></li>
<li> Gemert <it>et. al.</it> [3] provided theirs version of parsed annotations <a href="<https://github.com/jvgemert/apt">apt</a><li>. It is kept under filename <code>annot_apt.mat</code>
</ol>

<p>There are various problem and advantages in these parsed version when compared to each other. 
For instance, Saha's version has most number of action instances but temporal labelling and consistency between different action instances is problem. 
Gemert's version is very much similar to Saha's one. 
Weinzaepfel's version doesn't pick up all the action instances, some videos doesn't even have one action instance, 
but bounding-boxes accuracy temporal labelling accuracy are slightly better than other version.
Parsing original was going to lead to similar problems.</p>

### Correction

<p> So, I went through the pain to look through the annotations of each video. 
I found that around 600 videos annotations of Saha's had some problems and 300 had decent annotations for those videos in either in Weinzaepfel's version or Gemert's version.
Finally, rest required more intelligent combination of three versions. At the the end, we ended up with 3194 videos with good annotations in filename <code>finalAnnots.mat</code>. 
We had to remove 9 videos for which we couldn't manage re-annotation, 4 were test videos and 6 train videos. There may be 5-10 videos which still might have some error in annotations.</p>

After feedback from [Philippe Weinzaepfel](http://www.xrce.xerox.com/About-XRCE/People/Philippe-Weinzaepfel), 
I found there were about 30 tubes with wrong bounding boxes or duration of tubes was different than number of boxes. 
So, I looked at those tubes visually and corrected the boxes manually. 
At present there are 3194 videos with correct annotations. All the bounding boxes are within image boundaries and temporal durations are within the temporal bounds of videos.

### Download
This repository has new and old annotations in root directory itself. But, you can also download it from [google drive](https://drive.google.com/drive/folders/0B-LzM05qEdk0MU1kT01hbk50SWM?usp=sharing).
Either you can download videos of UCF101 and extract it yourself, we used ffmpeg -<videoname> <extractionDirectory/%05d.jpg> to extract the images. 

OR 

You can also donwload

[RGB images for 24 classes of UCF101 (2GB)](https://drive.google.com/drive/folders/0B-LzM05qEdk0MU1kT01hbk50SWM?usp=sharing)

[Results (100MB)](https://drive.google.com/drive/folders/0B-LzM05qEdk0MU1kT01hbk50SWM?usp=sharing) 


### Performance Numbers
<p>We have evaluated the approach of [1] and [5] and report the performance of their approaches on older annotations from [1] 
and new corrected annotations annotations. These results are produced on 911 test videos of split 1.</p>

Below is the table using older annotations from [1]

<table style="width:100%">
  <tr>
    <td>IoU Threshold = </td>
    <td>0.20</td> 
    <td>0.50</td>
    <td>0.75</td>
    <td>0.5:0.95</td>
  </tr>
  <tr>
    <td align="left">Peng et al [4] RGB+FLOW </td> 
    <th>73.55</th>
    <td>30.87</td>
    <td>01.01</td> 
    <td>07.11</td>  
  </tr>
  <tr>
    <td align="left">Saha et al [1] RGB+FLOW </td> 
    <td>67.89</td>
    <td>36.87</td> 
    <td>06.78</td>
    <td>14.29</td>
  </tr>
  <tr>
    <td align="left">Singh et al [5] RGB+FastFLOW </td> 
    <td>69.12</td>
    <td>41.16</td> 
    <td>10.31</td>
    <td>17.19</td>
  </tr>
  <tr>
    <td align="left">Singh et al [5] RGB+FLOW </td> 
    <td>70.73</td>
    <th>43.20</th> 
    <th>10.43</th>
    <th>18.02</th>
  </tr>
</table>


Below is the table using new corrected annotations.

<table style="width:100%">
  <tr>
    <td>IoU Threshold = </td>
    <td>0.20</td> 
    <td>0.50</td>
    <td>0.75</td>
    <td>0.5:0.95</td>
  </tr>
  <tr>
    <td align="left">Peng et al [4] RGB+FLOW </td> 
    <th>73.67</th>
    <td>32.07</td>
    <td>00.85</td> 
    <td>07.26</td>  
  </tr>
  <tr>
    <td align="left">Saha et al [1] RGB+FLOW </td> 
    <td>66.55</td>
    <td>36.37</td> 
    <td>07.94</td>
    <td>14.37</td>
  </tr>
  <tr>
    <td align="left">Singh et al [5] RGB+FastFLOW </td> 
    <td>67.69</td>
    <td>40.06</td> 
    <td>11.09</td>
    <td>17.30</td>
  </tr>
  <tr>
    <td align="left">Singh et al [5] RGB+FLOW </td> 
    <td>69.34</td>
    <th>42.53</th>
    <th>11.62</th> 
    <th>18.25</th>  
  </tr>
</table>


If you want to regenerate those number please go to [google drive link](https://drive.google.com/drive/folders/0B-LzM05qEdk0MU1kT01hbk50SWM?usp=sharing).
Then, download the *results* folder in to root directory of this repository from download 
Now, you can run <code>compute_mAPs.m</code> form inside the *evaluation* folder.

### Conclusion
Difference from above number might seem small, in my view having better annotations is good for the community. 
Also, it serves as baseline for future works. So, results of future works are directly comparable to previous state-of-the-art methods [1,4,5]. 
We recommend using provided evaluation script to evaluate your method. We will try to keep updating this page with additional numbers from other methods.

Please send me final results in same format as of provided for [1] and [5]. It is same format as annotations.
### Citing
If you use above annotation in your work, please cite the origibal UCF101 dataset 


      @article{soomro2012ucf101,
        title={UCF101: A dataset of 101 human actions classes from videos in the wild},
        author={Soomro, Khurram and Zamir, Amir Roshan and Shah, Mubarak},
        journal={arXiv preprint arXiv:1212.0402},
        year={2012}
      }

 
Also Please consider citing 


      @article{singh2016online,
        title={Online Real time Multiple Spatiotemporal Action Localisation and Prediction},
        author={Singh, Gurkirt and Saha, Suman and Sapienza, Michael and Torr, Philip and Cuzzolin, Fabio},
        journal={arXiv preprint arXiv:1611.08563},
        year={2016}
      }



### References
<ol>
<li> S. Saha, G. Singh, M. Sapienza, P. H. S. Torr, and F. Cuzzolin, Deep learning for detecting multiple space-time action tubes in videos. In British Machine Vision Conference, 2016</li>
<li> P. Weinzaepfel, Z. Harchaoui, and C. Schmid, Learning to track for spatio-temporal action localization. In IEEE Int. Conf. on Computer Vision and Pattern Recognition, June 2015 </li>
<li> J. C. van Gemert, M. Jain, E. Gati, and C. G. Snoek. Apt: Action localization proposals from dense trajectories. In BMVC, volume 2, page 4, 2015.</li>
<li> X. Peng and C. Schmid. Multi-region two-stream R-CNN for action detection. In ECCV 2016 - European Conference on Computer Vision, Amsterdam, Netherlands, Oct. 2016.</li>
<li> G. Singh, S Saha, M. Sapienza, P. H. S. Torr and F Cuzzolin. "Online Real time Multiple Spatiotemporal Action Localisation and Prediction." arXiv preprint arXiv:1611.08563 (2016).</li>
<ol>
