import scipy.io as scio
import cPickle as pickle
import numpy as np
import gzip

if __name__ == '__main__':

    rawAnnotations = scio.loadmat('finalAnnots.mat')
    rawAnnotations = rawAnnotations['annot'][0] # Squeeze to one dimension

    annotDict = {}

    gtId = 0
    numSeq = 0

    for annotation in rawAnnotations:
        name = annotation[1][0].encode('ascii')
        numIms = annotation[0][0].astype(np.int32)
        numTubes = annotation[2].shape[1]  # tubes are in 1 x N format
        objectDict = {}
        for tubeId in range(numTubes):
            sf = annotation[2][0][tubeId][1][0][0].astype(np.int32)
            ef = annotation[2][0][tubeId][0][0][0].astype(np.int32)
            classId = annotation[2][0][tubeId][2][0][0].astype(np.int32)
            boxes = annotation[2][0][tubeId][3].astype(np.int32)
            objectId = gtId
            gtId += 1
            objectDict[tubeId] = {
                                    'sf' : sf,
                                    'ef' : ef,
                                    'classId' : classId,
                                    'gtId' : objectId,
                                    'boxes' : boxes
            }
        annotDict[name] = {
                            'name':name,
                            'numIms':numIms,
                            'numObjects':numTubes,
                            'objects':objectDict
        }

        numSeq += 1

    print "Total Number of Boxes : {}".format(gtId)
    print "Total Number of Sequences : {}".format(numSeq)
    annotDict['numGTs'] = gtId
    annotDict['numSeq'] = numSeq

    with gzip.GzipFile('UCF101_annots.gz', 'wb') as fid:
        fid.write(pickle.dumps(annotDict))


