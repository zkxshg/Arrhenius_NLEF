% 读取 Excel 文件
filename = 'errormatrix.xlsx';
T = readtable(filename);

% 初始猜测参数值
initial_guess = [1, 1, 1];  % 根据你的实际情况调整

for i = 1:size(T, 1)
    inde_matrix = zeros(3, 17);
    inde_matrix(1, :) = T{i, 1};  % 应变速率
    inde_matrix(2, :) = T{i, 2};  % 开尔文温度
    inde_matrix(3, :) = 0.05 : 0.05 : 0.85;  % 应变区间
    % disp(inde_matrix);

    error_vector = T{i, 3:19};  % 误差值
    % disp(error_vector);

    % 使用 nlinfit 进行参数拟合
    parameters = nlinfit(inde_matrix', error_vector', @myfun, initial_guess);
    
    % 输出拟合结果
    disp(parameters);
end

%%
function error_estimate = myfun(params, inde_vars)
    % params 是参数向量，假设包含三个元素: [a, b, c]
    % inde_vars 是一个 17x3 的矩阵，对应于 17 个观测值的三个自变量
    % 该函数返回一个 17x1 的误差估计向量
    
    a = params(1);
    b = params(2);
    c = params(3);
    
    % 假设误差模型是: a * 应变速率 + b / 温度 + c * 应变
    strain_rate = inde_vars(:, 1);
    temperature = inde_vars(:, 2);
    strain = inde_vars(:, 3);
    
    % 计算模型的预期响应
    error_estimate = a * strain_rate + b ./ temperature + c * strain;
end