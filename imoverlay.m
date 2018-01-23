function out = overlay(input, mask, color)
%IMOVERLAY Create a mask-based image overlay.
%   OUT = IMOVERLAY(IN, MASK, COLOR) takes an input image, IN, and a binary
%   image, MASK, and produces an output image whose pixels in the MASK
%   locations have the specified COLOR.
%
% 

% If the user doesn't specify the color, use white.
DEFAULT_COLOR = [1 0 0];
if nargin < 3
    color = DEFAULT_COLOR;
end

% Force the 2nd input to be logical.
mask = (mask ~= 0);

% Make the uint8 the working data class.  The output is also uint8.

color_uint8 = im2uint8(color);

% Initialize the red, green, and blue output channels.

    % Input is grayscale.  Initialize all output channels the same.
out_red   = input;
out_green = input;
out_blue  = input;



% Replace output channel values in the mask locations with the appropriate
% color value.
out_red(mask)   = color_uint8(1);
out_green(mask) = color_uint8(2);
out_blue(mask)  = color_uint8(3);

% Form an RGB truecolor image by concatenating the channel matrices along
% the third dimension.
out = cat(3, out_red, out_green, out_blue);
