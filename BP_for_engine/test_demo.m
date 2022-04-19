BPfortraining = load('BP_for_training.txt');
BPfortesting = load('BP_for_testing.txt');
Engine_fuel = BPfortraining(:,2)';
Engine_RPM = BPfortraining(:,1)'; 

Engine_test_fuel = BPfortesting(:,2)';
Engine_test_RPM = BPfortesting(:,1)';
N = size(Engine_test_fuel,2);

[engine_fuel, Strain_input] = mapminmax(Engine_fuel,0,1);
[engine_test_fuel, Stest_input] = mapminmax(Engine_test_fuel,0,1);
[engine_RPM, S_output] = mapminmax(Engine_RPM,0,1);

net = newff(engine_fuel,engine_RPM,[5,2]);
net.trainParam.show = 50;
net.trainParam.epochs = 10000;
net.trainParam.goal = 1e-6;
net.trainParam.lr = 0.005;

net = train(net,engine_fuel,engine_RPM);
engine_RPM_sim = sim(net,engine_test_fuel);
% 
Engine_RPM_sim = mapminmax('reverse',engine_RPM_sim,S_output);
error = abs(Engine_RPM_sim - Engine_test_RPM)./Engine_test_RPM;
result = [Engine_test_RPM' Engine_RPM_sim' error'];

R2 = (N * sum(Engine_RPM_sim .* Engine_test_RPM) - sum(Engine_RPM_sim) * sum(Engine_test_RPM))^2 / ((N * sum((Engine_RPM_sim).^2) - (sum(Engine_RPM_sim))^2) * (N * sum((Engine_test_RPM).^2) - (sum(Engine_test_RPM))^2));

plot(1:N,Engine_test_RPM,'b:*',1:N,Engine_RPM_sim,'r-o')
legend('真实值','预测值')
xlabel('预测样本')
ylabel('转速')
string = {'转速预测结果对比';['R^2=' num2str(R2)]};
title(string)