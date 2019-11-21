function numberPlateExtraction

f=imread('car3.jpg'); % Input Image whose characters has to be extracted
f=imresize(f,[400 NaN]); % Resize original Image to required dimension       %Not Possible 800 line code

% Converting RGB Image to Gray Image
X = f;
is3D = (ndims(X) == 3);
if is3D
   
    if (size(X,3) ~= 3)
        error(message('MATLAB:images:rgb2gray:invalidInputSizeRGB'))
    end
    
    validateattributes(X, {'numeric'}, {}, mfilename, 'RGB');
elseif ismatrix(X)
    
    if (size(X,2) ~= 3 || size(X,1) < 1)
        error(message('MATLAB:images:rgb2gray:invalidSizeForColormap'))
    end
    
    if ~isa(X,'double')
        error(message('MATLAB:images:rgb2gray:notAValidColormap'))
    end
else
    error(message('MATLAB:images:rgb2gray:invalidInputSize'))
end

isRGB = is3D;

if isRGB
    I = images.internal.rgb2graymex(X);
else
    
    T    = inv([1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703]);
    coef = T(1,:);
    I = X * coef';
    I = min(max(I,0),1);
    I = repmat(I, [1 3]);
end
g = I;
% End of RGB --> Gray Conversion Code 

g=medfilt2(g,[3 3]);
se=strel('disk',1); % Not possible 1508 line code
gi=imdilate(g,se); 
ge=imerode(g,se);  

% Internal Code for imsubtract
scalarDoubleY = isa(ge,'double') && numel(ge) == 1;

if ~islogical(gi)
    xAndYSameSizeAndClass = isequal(size(gi),size(ge)) && ...
        strcmp(class(gi), class(ge));

    if scalarDoubleY || xAndYSameSizeAndClass
        validateattributes(gi, {'numeric','logical'}, {'real', 'nonsparse'}, ...
            mfilename, 'gi', 1);
        if scalarDoubleY
            validateattributes(ge, {'double'}, {'real', 'nonsparse'}, ...
                mfilename, 'ge', 2);
        else
            validateattributes(ge, {'numeric','logical'}, {'real', 'nonsparse'}, ...
                mfilename, 'ge', 2);
        end
        Z = gi - ge;
    else
        error(message('images:imsubtract:invalidInput'));
    end

elseif scalarDoubleY
    Z = imlincomb(1.0, gi, -ge, 'double');

else
    Z = imlincomb(1.0, gi, -1.0, ge, 'double');
end
gdiff = Z;
% End of internal code for imsubtract

gdiff=mat2gray(gdiff); 
gdiff=conv2(gdiff,[1 1;1 1]); 
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1); 
B=logical(gdiff);
er=imerode(B,strel('line',50,0));


% internal code for imsubtract

scalarDoubleY = isa(er,'double') && numel(er) == 1;

if ~islogical(B)
    xAndYSameSizeAndClass = isequal(size(B),size(er)) && ...
        strcmp(class(B), class(er));

    if scalarDoubleY || xAndYSameSizeAndClass
        validateattributes(B, {'numeric','logical'}, {'real', 'nonsparse'}, ...
            mfilename, 'B', 1);
        if scalarDoubleY
            validateattributes(er, {'double'}, {'real', 'nonsparse'}, ...
                mfilename, 'er', 2);
        else
            validateattributes(er, {'numeric','logical'}, {'real', 'nonsparse'}, ...
                mfilename, 'er', 2);
        end
        Ze = B - er;
    else
        error(message('images:imsubtract:invalidInput'));
    end

elseif scalarDoubleY
    Ze = imlincomb(1.0, B, -er, 'double');

else
    Ze = imlincomb(1.0, B, -1.0, er, 'double');
end

out1=Ze;
% End for internal code

F=imfill(out1,'holes'); % Not Possible 250 line code

H=bwmorph(F,'thin',1);   % On hold

H=imerode(H,strel('line',3,90));  % Not possible

final=bwareaopen(H,100);  % Not possible

Iprops=regionprops(final,'BoundingBox','Image');  % Not possible because of .p file

NR=cat(1,Iprops.BoundingBox); % build-in funtion

r=controlling(NR);  % Call to controlling.m file for further process
if ~isempty(r) 
    I={Iprops.Image}; 
    noPlate=[]; 
    for v=1:length(r)
        N=I{1,r(v)};
        letter=readLetter(N); 
        while letter=='O' || letter=='0' 
            if v<=3                     
                letter='O';              
            else                         
                letter='0';              
            end                         
            break;                       
        end
        noPlate=[noPlate letter]; 
    end
    % printing in  .txt file
    fid = fopen('noPlate.txt', 'wt'); 
    fprintf(fid,'%s : Characters on Vehicle Number Plate\n',noPlate);   % Printing characters on .txt file   
    fclose(fid);
    winopen('noPlate.txt') % txt file
      
else % Error Message if unable to extract characters
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end
end