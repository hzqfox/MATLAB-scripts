
function overlay(input, mask, color)



    %default color is white
    DEFAULT_COLOR = [1 1 1];
    if nargin ==0
        input = evalin('base','rawStack');
        mask = evalin('base','segStack');
        color = DEFAULT_COLOR;
    elseif nargin < 3
        color = DEFAULT_COLOR;
    end
    
    %timing function running duration
    disp('Overlaying mask (segmentation stack) onto FIBSEM image stack, this may takes a while...');tic;
    
    %convert color to unsigned-8bit form
    color_uint8 = im2uint8(color);
    %color_uint8=[255,255,0];

    sizeOfStack = size(input);
    slices = sizeOfStack(3);
    x = evalin('base','X');
    y = evalin('base','Y');
    z = evalin('base','Z');

    %assign segmentation to boolean type RGB channels
    red_channel=mask;
    green_channel=mask;
    blue_channel=mask;

    %split RGB channels; red for segmentation, and blue for false-positive
    red_channel=(red_channel==2);
    %green_channel=(green_channel==1);
    blue_channel=(blue_channel==1);

    %assign output RGB channels
    red=input;
    blue=input;
    green=input;

    %use segmentation data to assign color to output
    red(red_channel)=color_uint8(1);
    %green(green_channel)=color_uint8(2);
    blue(blue_channel)=color_uint8(2);

    %out = double(zeros(x,y,3,z));
    out = uint8(zeros(x,y,3,z));
    %out = uint8(zeros(1024,1024,3,512));

    %converge RGB channel together to output image
    for i = 1: slices    
    out(:,:,:,i) = cat(3,red(:,:,i),green(:,:,i),blue(:,:,i));
    end

    MakeMyVar('Overlay',out);
    disp('done!');
    
    toc;

end