clear;clc
f1=imread('49.bmp');
f1=f1(70:730,206:818);
w=fspecial('average',3);
fa=imfilter(f1,w,'replicate');
T=graythresh(fa);
g=im2bw(fa,T);
g1=edge(g,'sobel');
g1=bwmorph(g1,'thin',inf);
[L,num]=bwlabel(g1);
len=zeros(num,1);
for i=1:num
    idx{i}=find(L==i);
    len(i)=length(idx{i});
end
[sl,id1]=sort(len,'descend');
len_av=mean(len);
is_large=sl>=mean(len);
id1_large=id1.*is_large;
g2=zeros(size(g1));
idx1=cell(sum(is_large),1);
for i=1:length(id1_large)
    if id1_large(i)>0
        g2(idx{id1(i)})=1; 
        idx1{i}=idx{id1(i)};
    end
end
ep=endpoints(g2);
[lox,loy]=find(ep==1);
for i=1:length(lox)
    t1=lox(i);
    t2=loy(i);
    if ((15<t1) && (t1<size(ep,1)-15) && (15<t2) && (t2<size(ep,2)-15) && (ep(t1,t2)==1))
       patch=ep(t1-15:t1+15,t2-15:t2+15);
       ep(t1,t2)=0;
       patch(16,16)=0;
       [neighx,neighy]=find(patch==1);
       if ~isempty(neighx)
           rx=neighx-16;
           ry=neighy-16;
           [min_d,l]=min(abs(rx)+abs(ry));
           rx=rx(l);
           ry=ry(l);
           locx=t1+rx;
           locy=t2+ry;
           [x,y]=intline(t1,locx,t2,locy);
           for k=1:length(x)
            g2(x(k),y(k))=1;
           end
           for j=1:length(lox)
               if lox(j)==locx && loy(j)==locy;
                   lox(j)=0;
                   loy(j)=0;
               end
           end
       end
   end
end
    
g4=zeros(size(g2));
[Lc,numc]=bwlabel(g2);
idx2=cell(numc,1);
for i=1:numc
    idx2{i}=find(Lc==i);
    [I,J]=ind2sub(size(g1),idx2{i});
    if max(J)-min(J)<0.5*size(g2,2)
        idx2{i}=[];
    end
end
count=1;
for i=1:length(idx2)
    if ~isempty(idx2{i})
        idx3{count}=sub2ind(size(g1),idx2{i});
        count=count+1;
    end
end
loc=zeros(length(idx3),1);
for i=1:length(idx3)
    g4(idx3{i})=1;
    [I,J]=ind2sub(size(g1),idx3{i});
    idx3{i}=[I,J];
    loc(i)=mean(I);
    idx3{i}=sub2ind(size(g1),idx3{i}(:,1),idx3{i}(:,2));
end
[sloc,id2]=sort(loc);
loc_d=diff(sloc);
[sloc_d,id3]=sort(loc_d,'descend');
cou=0;
for i=1:3
   g5=zeros(size(g4));
   g6=zeros(size(g4));
   g7=zeros(size(g4));
   g8=zeros(size(g4));
   g5(idx3{id2(id3(i))})=1;
   g6(idx3{id2(id3(i)+1)})=1;
   for j=1:size(g5,2)
        col_vec_1=g5(:,j);
        m_1=max(col_vec_1);
        if m_1==1
            id5=find(col_vec_1==1);
            g7(max(id5),j)=1;
        end
        col_vec_2=g6(:,j);
        m_2=max(col_vec_2);
        if m_2==1
            id6=find(col_vec_2==1);
            g8(min(id6),j)=1;
        end
    end
    g9=g7|g8;
    [r1,c1]=find(g7==1);
    [r2,c2]=find(g8==1);
    cmin=max(min(c1),min(c2));
    cmax=min(max(c1),max(c2));
    num_g=0;
    gray=0;
    for k=cmin:cmax
        num_g=num_g+find(g8(:,k)==1)-find(g7(:,k)==1);
        gray=gray+sum(f1(find(g7(:,k)==1):find(g8(:,k)==1),k));
    end
    avg=gray/num_g;
    if avg<40
        break;
    end
    cou=cou+1;
end
if cou==3 || sloc_d(i)<60
    g5=zeros(size(g4));
    g7=zeros(size(g4));
    g5(idx3{id2(length(idx3))})=1;
    for j=1:size(g5,2)
        col_vec_1=g5(:,j);
        m_1=max(col_vec_1);
        if m_1==1
            id5=find(col_vec_1==1);
            g7(max(id5),j)=1;
        end
    end
    [r1,c1]=find(g7==1);
    r2=[];
    c2=[];
end

imshow(f1);
hold on
plot(c1,r1,'r');
plot(c2,r2,'r');