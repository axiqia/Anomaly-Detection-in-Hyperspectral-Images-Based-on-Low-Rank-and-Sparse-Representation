%  predict       - 分类器对测试集的分类结果
%  ground_truth - 测试集的正确标签,这里只考虑二分类，即0和1
%  auc            - 返回ROC曲线的曲线下的面积
function auc = AUC(ground_truth,predict)
%初始点为（1.0, 1.0）
%计算出ground_truth中正样本的数目pos_num和负样本的数目neg_num

pos_num = sum(ground_truth==1);
neg_num = sum(ground_truth==0);

m=size(ground_truth,1);
[pre,Index]=sort(predict);
ground_truth=ground_truth(Index);
x=zeros(m+1,1);
y=zeros(m+1,1);
auc=0;
x(1)=1;y(1)=1;

for i=2:m
TP=sum(ground_truth(i:m)==1);FP=sum(ground_truth(i:m)==0);
x(i)=FP/neg_num;
y(i)=TP/pos_num;
auc=auc+(y(i)+y(i-1))*(x(i-1)-x(i))/2;
end;

x(m+1)=0;y(m+1)=0;
auc=auc+y(m)*x(m)/2;
plot(x,y);
end