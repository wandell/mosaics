% image mosaics:  Structure for the new mosaic code
%
% I think the local directory at wandell's home has these test data.
%
% Put them on the RDT, maybe.

%% This is one example data set
curDir = cd;
originalImageDir = fullfile(mosaicsRootPath,'local','mosaics','TRY','originalTiles');
subImageDir      = fullfile(mosaicsRootPath,'local','mosaics','TRY','subImage');
baseImageDir     = fullfile(mosaicsRootPath,'local','mosaics','TRY','baseImage');

dataDir       = fullfile(mosaicsRootPath,'local','mosaics','TRY'); 
bname         = 'fruit512';
baseImageName = fullfile(baseImageDir,bname);
disp(baseImageName);

%% Another example data set
%{
curDir = cd;
originalTileDir = '/home/wandell/mosaics/panthers/originalTiles/';
subImageDir = '/home/wandell/mosaics/panthers/subImage/';
baseImageDir = '/home/wandell/mosaics/panthers/baseImage/';
dataDir = '/home/wandell/mosaics/panthers/';
bname = 'lion';
baseImageName = [baseImageDir, bname];
disp(baseImageName);
%}

%% This seems to build up the collection of tiles for the mosaic

% This script might require having all the data files in place
% instead of doing this.
%
cd(dataDir)
if exist('mosaicData','file')
    % If the file was built already, load it
    disp('Loading existing mosaicData file')
    load mosaicData
else
    nGray = 220;
    crop = [1 1; 64 64];
    tileRow = 128; tileCol = 128;
    disp('Creating sub-images and building mosaicData file')
    CreateSubImages
    
    cd(dataDir)
    save mosaicData originalImageDir subImageDir nGray crop tiffFiles
end

% This routine allows the tile images to be different sizes.  We
% aren't set up for that yet.
scaleFactor = 2;
tileImages = readTileImages(subImageDir,[tileRow tileCol],scaleFactor);
baseImage  = imread(baseImageName,'tif');
tileSize = size(tileImages);

%% Change base image to be a multiple of the tiles.
nRow = floor(size(baseImage,1)/tileSize(1))*tileSize(1);
nCol = floor(size(baseImage,2)/tileSize(2))*tileSize(2);
baseImage = baseImage(1:nRow,1:nCol);
baseImageSize = size(baseImage);

%% Seems to do the work
tileImage = placeTiles(baseImageSize,tileImages,'t');

% vcNewGraphWin;
%image(tileImage), colormap(gray(256)), axis image

%% This must do something
[r, g, b] = blendImages(baseImage,tileImage,tileSize);

%% Write it out with some kind of reasonable name
% This is drawn from the parameters of the calls
%
mosaicName = [bname,num2str(tileRow/scaleFactor),'.tif'];
fprintf('Saving first mosaic:  %s\n',mosaicName);

% Probably needs to be imwrite, different architecture.
changeDir(dataDir), tiffwrite(r,g,b,mosaicName);
% unix(['xv -perfect ',mosaicName,' &']);

%% Now what?
SplinedTileImage = splineTile(tileImage,tileSize,3);

[mosaicImage, mosaicMap] = rgb2ind(rs,gs,bs);

%% End