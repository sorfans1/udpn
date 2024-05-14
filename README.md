# 使用环境
需要先安装Autohotkey
# 计分公式
score=Round(21.916*(1.571-ATan(1.5*(key_per_word-2.5)))*(1.571+0.5915*ATan(0.05*(input_speed-50)))*correct_rate,1)  
if(score>100) score=100  
key_per_word是码长，即为了输入一个字而敲了多少下键盘。key_per_word越小得分越高。  
input_speed是每分钟输入了多少字。input_speed越大得分越高。  
correct_rate是输入正确率。  
# 快捷键
Alt+Enter：开始练习  
Ctrl+Enter：下一题
