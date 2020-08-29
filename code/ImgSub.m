function A = ImgSub(A, B, start_xy)
    %ImgSub: subtract B from A
    %Input    A                 : n1*n2 array to be subtracted
    %         B                 : h*w array
    %         start_xy          : 1*2 array, middle position of the B
    %Output:  A                 : has the same size with region
    start_xy = ceil(start_xy);
    x = start_xy(1);
    y = start_xy(2);
    [h,w] = size(B); 
    A(x-h/2+1:x+h/2, y-w/2+1:y+w/2) = A(x-h/2+1:x+h/2, y-w/2+1:y+w/2)-B; 
end