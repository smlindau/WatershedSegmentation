function bacteriaStats = detectEcoli(image,seSize,seSize2,mult,focus)
if nargin == 3
    focus = 1;
end
% Normalize and invert the image
image = getNormalized(image);
image = 1 - image;
% Create a convolution kernel in a disk shape and of input radius
se = strel('disk',seSize);
% Convolve the image with the kernel disk
subBkgdImage = imtophat(image,se);
% If the image is out of focus, apply the following filtering
if ~focus
    subBkgdImage = imsharpen(imgaussfilt(subBkgdImage,2),...
        'Amount',4,'Radius',seSize2,'Threshold',.1);
end
% Assign a threshold value from input and binarize the image
thresholdValue = graythresh(subBkgdImage)*mult;
bwImage = bwareaopen(imbinarize(subBkgdImage,thresholdValue),10);
    % imshow(bwImage)
% Determine the distance transform fo the binary image such that each pixel
% is assigned a value based on its distance to the nearest nonzero value
bwDist = -bwdist(~bwImage);
bwDist(~bwImage) = Inf;
    % imshow(bwDist,[])
% Compute the extended-minima transform with a scalar h of 1
bwMask = imextendedmin(bwDist,1);
    % imshow(bwMask)
    % imshowpair(bwImage,bwMask,'blend')
% Impose the minima transform onto the binary image
bwDist = imimposemin(bwDist,bwMask);
    % imshow(bwDist,[])
% With the imposed minima, apply the watershed transform to the image to
% separate out 'touching' particles
segmentImage = watershed(bwDist);
holdImage = bwareaopen(bwImage,50);
holdImage(segmentImage == 0) = 0;
imshow(holdImage)
segmentImage(~holdImage) = 0;
rgb = label2rgb(segmentImage,'hsv',[0 0 0],'shuffle');
% rgb = double(rgb);
imshowpair(rgb,image,'blend')
% imshow(rgb)
finalImage = bwareaopen(holdImage,50);
bacteriaStats = regionprops(finalImage,'Orientation','Centroid','Area');
% toc
end
