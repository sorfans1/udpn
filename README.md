# 使用环境
需要先安装Autohotkey
# 计分公式
score=Round(21.916*(1.571-ATan(1.5*(key_per_word-2.5)))*(1.571+0.5915*ATan(0.05*(input_speed-50)))*correct_rate,1)  
if(score>100)  
  score=100  
其中key_per_word是码长，input_speed是每分钟多少字。
# 快捷键
Alt+Enter：开始练习  
Ctrl+Enter：下一题
