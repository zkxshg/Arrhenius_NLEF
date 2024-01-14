% === 定义输入变量 ===
% 应变范围
x = 0.05 : 0.05 : 0.85; 

% 定义摄氏度温度
T_cel = [250, 300, 350, 400, 450];
% T_cel = 523
% 转换为卡尔文温度
T_kel = T_cel + 273.15;

%  变形速率
d_x = [0.001, 0.01, 0.1, 1, 10];

% 理想气体常量，单位为 J/(mol*K)
R = 8.314; 

% 组织因数: lnA
result_lnA = lnA(x);
result_A = exp(result_lnA);

% 变形激活能: Q
result_Q = Q(x);

% 应力水平因数: alpha
result_alpha = alpha(x);

% 应力指数因数: n2
result_n2 = n2(x);

% 预测应力
stressMatrix = calculatePredictedStress(result_alpha, result_Q, result_A, result_n2, T_kel, d_x);

writeToCSV('predicted_stress.csv', d_x, T_kel, stressMatrix, result_alpha);
%disp(stressMatrix(1, 1, :));

function result = lnA(x)
    result = 30.05649 - 26.0829*x + 195.1135*x.^2 - 502.72033*x.^3 + 559.27471*x.^4 - 229.30897*x.^5;
end

function result = Q(x)
    result = 177388.12681 - 204594.72679*x + 1.44878E6*x.^2 - 3.66706E6*x.^3 + 4.04484E6*x.^4 - 1.64704E6*x.^5;
end

function result = alpha(x)
    result = 0.01332 - 0.0313*x + 0.18169*x.^2 - 0.41041*x.^3 + 0.42486*x.^4 - 0.16563*x.^5;
end

function result = n2(x)
    result = 7.64079 - 13.13494*x + 64.45414*x.^2 - 148.68193*x.^3 + 158.28002*x.^4 - 63.21636*x.^5;
end

function result = ArreniusConst(alpha, dot_epsilon, Q, A, n, T_kel)
    R = 8.314; % 理想气体常量，单位为 J/(mol*K)
    result = (1./alpha) .* log(((dot_epsilon .* exp(Q ./ (R .* T_kel)) ./ A).^(1./n) + (dot_epsilon .* exp(Q ./ (R .* T_kel)) ./ A).^(2./n) + 1).^(1/2));
end

function predicted_stress = calculatePredictedStress(alpha, Q, A, n, T_kel, d_x)
    predicted_stress = zeros(length(d_x), length(T_kel), length(alpha));

    for i = 1:length(d_x)  % 变形速率i
        for j = 1:length(T_kel)  % 温度j
            result = ArreniusConst(alpha, d_x(i), Q, A, n, T_kel(j));
            disp(d_x(i)); disp(T_kel(j)); disp(result);
            predicted_stress(i, j, :) = result;
        end
    end
end

function writeToCSV(filename, d_x, T_kel, stressMatrix, alpha)
    % 打开文件以进行写入
    fileID = fopen(filename, 'w');

    % 写入列标签
    fprintf(fileID, 'd_x, T_kel,');
    for k = 1:length(alpha)
        fprintf(fileID, 'epsilon_%d,', k);
    end
    fprintf(fileID, '\n');

    % 写入数据
    for i = 1:length(d_x)
        for j = 1:length(T_kel)
            % 写入 d_x 和 T_kel 值
            fprintf(fileID, '%f, %f,', d_x(i), T_kel(j));

            % 写入 stressMatrix 对应的值
            for k = 1:length(alpha)
                result = stressMatrix(i, j, k);
                fprintf(fileID, '%f,', result);
            end
            fprintf(fileID, '\n');
        end
    end

    % 关闭文件
    fclose(fileID);
end