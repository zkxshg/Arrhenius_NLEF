% 读取 Excel 文件,文件中包含4个425维的，分别代表3个自变量和1个因变量的列向量。
filename = 'data.xlsx';
Data = readtable(filename);

%自定义拟合函数
%fun中的t(:,1)为应变速率，t(:,2)为温度，t(:,3)为应变量
myfun = @(k,t) k(1) + k(2).*t(:,1) + k(3).*t(:,2) + k(4).*t(:,3) + ... 
    k(5).*t(:,1).^2 + k(6).*t(:,2).^2 + k(7).*t(:,3).^2 + ... 
    k(8).*t(:,1).*t(:,2) + k(9).*t(:,1).*t(:,3) + k(10).*t(:,2).*t(:,3) + ...
    k(11).*t(:,1).^3 + k(12).*t(:,2).^3 + k(13).*t(:,3).^3 + ...
    k(14).*t(:,1).^2.*t(:,2).*t(:,3) + k(15).*t(:,1).*t(:,2).^2.*t(:,3) + k(16).*t(:,1).*t(:,2).*t(:,3).^2 + ...
    k(17).*t(:,1).^4 + k(18).*t(:,2).^4 + k(19).*t(:,3).^4;

% 初始猜测参数值
% k0 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
k0 = ones(1, 19);

%设置自变量和因变量
%xdata=[Data(:,1),Data(:,2),Data(:,3)];
%ydata=Data(:,4);
xdata = table2array(Data(:,1:3));
ydata = table2array(Data(:,4));

% 数据标准化
xdata_normalized = (xdata - mean(xdata)) ./ std(xdata);

%lsqcurvefit拟合，参数拟合方法为最小二乘法
% [x,resnorm,~,exitflag,output] = lsqcurvefit(myfun,k0,xdata,ydata);
% params 是参数向量
% parameters = [k(1),k(2),k(3),k(4),k(5),k(6),k(7),k(8),k(9),k(10),k(11),k(12),k(13),k(14),k(15),k(16),k(17),k(18),k(19)];

% 使用 lsqcurvefit 进行拟合，参数拟合方法为最小二乘法
options = optimoptions('lsqcurvefit','Display','iter');
[x,resnorm,residual,exitflag,output] = lsqcurvefit(myfun,k0,xdata_normalized,ydata,[],[],options);


% 输出拟合结果
% disp(parameters)

% 输出拟合结果
disp('参数值:');
disp(x);
disp('残差平方和:');
disp(resnorm);

% 使用最佳拟合参数计算预测值
predicted_values = myfun(x, xdata_normalized);

% 计算预测误差
errors = ydata - predicted_values;

% 将预测值和误差加入原始数据表格
Data.predicted_values = predicted_values;
Data.errors = errors;

% 保存更新后的表格为新的 Excel 文件
new_filename = 'updated_data.xlsx';
writetable(Data, new_filename);

% 保存训练后的参数值
T = array2table(x', 'VariableNames', {'Parameters'});
writetable(T, 'modelParameters.csv');

