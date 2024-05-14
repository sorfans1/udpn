#Requires AutoHotkey v2.0
#SingleInstance force
SetTitleMatchMode 2

isStart:=false
presskey_num_total:=[0,0]
idea_presskey_num_total:=0
wintitle:="输入速度测试-天津师范大学 信息技术在教学中的应用"
test_level:=1
test_max_level:=3

item_base:=[]


test_strs:=[]
i:=0
while(i<test_max_level){
	test_strs.push("")
	i++
}
test_str:=test_strs[1]

str_len_t_total:=0
str_len_s_total:=0
str_len_cs_total:=0
correct_char_num_total:=0

mainFrame:=Gui(,wintitle)

StuAnsEdit:=mainFrame.add("edit","x10 y65 w600 h50")
StuAnsEdit.OnEvent("Change", OnInput)
StuAnsEdit.SetFont("cBlack s14", "黑体")

StartTestBtn:=mainFrame.Add("button","x415 y455 w80 h25","开始")
StartTestBtn.OnEvent("Click",btnStartTest)
NextItemBtn:=mainFrame.Add("button","x515 y455 w80 h25","下一条")
NextItemBtn.OnEvent("Click",btnNextItem)

TextPreInputNum:=mainFrame.Add("text","x15 y125 w180 h25")
TextPreInputNum.SetFont("cBlack s14", "楷体")
TextPreInputNum.Value:="已输入字数："
TextInputNum:=mainFrame.Add("text","x120 y125 w80 h25")
TextInputNum.SetFont("cBlack s14", "楷体")
TextInputNum.Value:="0"

TextPreKeyNum:=mainFrame.Add("text","x260 y125 w180 h25")
TextPreKeyNum.SetFont("cBlack s14", "楷体")
TextPreKeyNum.Value:="击键次数："
TextKeyNum:=mainFrame.Add("text","x346 y125 w80 h25")
TextKeyNum.SetFont("cBlack s14", "楷体")
TextKeyNum.Value:="0"

TextPreTime:=mainFrame.Add("text","x465 y125 w80 h25")
TextPreTime.SetFont("cBlack s14", "楷体")
TextPreTime.Value:="用时："
TextTime:=mainFrame.Add("text","x515 y125 w80 h25")
TextTime.SetFont("cBlack s14", "楷体")
usedTime:=0
TextTime.Value:=usedTime "秒"
usedMaxTime:=600

ChangeUI(0)

TextAMaxNum:=60
TextA:=[] ;显示题目的文本框数组
i:=1
while(i<=TextAMaxNum){
	textname:="textt" i
	TextA.push(textname)
	;option中加入0x80，才可以显示符号&
	if(i<=31)
		textoption:="0x80 x" 10+19*(i-1) " y10" " w20 h20 v"
	else
		textoption:="0x80 x" 10+19*(i-32) " y30" " w20 h20 v"
	TextA[i]:=mainFrame.Add("text", textoption)
	i++
}

mainFrame.show("w620 h500")

OnTimer()
{
	global usedTime
	global usedMaxTime
	global test_level
	global str_len_s_total

	usedTime:=usedTime+1
	TextTime.Value:=usedTime "秒"

	if(usedTime>=usedMaxTime){
		MsgBox("时间到，开始算分。","时间到","0x40 T2")
		NextItem()
	}
}


ChangeUI(isBegin)
{
	global isStart
	if(isBegin==1){
		isStart:=true
		NextItemBtn.Enabled:=1
		StuAnsEdit.Enabled:=1
		StartTestBtn.Enabled:=0
	}
	else{
		isStart:=false
		NextItemBtn.Enabled:=0
		StuAnsEdit.Enabled:=0
		StartTestBtn.Enabled:=1
	}
}

OnInput(a,b)
{
	global test_str
	global presskey_num_total
	global idea_presskey_num_total
	global str_len_s_total
	
	str:=StuAnsEdit.Value
	str_len_s:=StrLen(str)
	i:=1
	while(i<=str_len_s and i<=60){
		st1:=TextA[i].Value
		st2:=substr(str,i,1)
		if(st1==st2){
			TextA[i].SetFont("cBlack s14", "黑体")
		}
		else{
			TextA[i].SetFont("cRed s14", "黑体")
		}
		i++
	}
	
	TextInputNum.Value:=str_len_s_total+str_len_s "/" str_len_t_total+StrLen(test_str)
	TextKeyNum.Value:=presskey_num_total[1]+presskey_num_total[2]
}

OnKeyPress(keytype:=1)
{
	global presskey_num_total
	presskey_num_total[keytype]++
	
	return
}

SelectItem()
{
	global item_base
	global test_strs
	
	byte_limit:=65536
	fid_limit:=3 ;共有多少数据文件
	fid:=Random(1,fid_limit)
	item_base:=[]
	fr_name:="r" fid ".txt"
	frp:=FileOpen(fr_name, "r","utf-8")
	str:=frp.ReadLine()
	n:=1
	while(StrLen(str)>0){
		str2:=""
		n:=InStr(str,",")
		if(n>=1){
			str_hash:=SubStr(str,1,n-1)
			while(n>=1){
				m:=InStr(str,",", ,n+1)
				if(m>n){
					chn:=SubStr(str,n+1,m-n-1)
					chn-=str_hash
					if(chn<=0)
						chn+=byte_limit
					str2:=str2 Chr(chn)
				}
				n:=m
			}
		}
		item_base.push(str2)
		str:=frp.ReadLine()
	}
	frp.Close()
	
	distance:=96
	ds:=[]
	rs:=[]
	firp:=FileOpen("i" fid ".txt", "r", "UTF-8")
	str:=firp.ReadLine()
	while(strlen(str)>0){
		str:=Mod(SubStr(str,1,InStr(str,"`n")-1),193)-distance
		ds.push(str)
		str:=firp.ReadLine()
		rs.push(0)
	}
	firp.close()
	dmax:=ds.Length
	rmax:=item_base.Length
	if(dmax!=rmax){
		MsgBox "database error"
		ExitApp
	}
	
	str_num:=test_strs.Length
	ni:=[]
	i:=1
	while(i<=str_num){
		ni.push(0)
		i++
	}
	
	i:=1
	while(i<=dmax){
        if(ds[i]<distance)
            ds[i]++
        if(i==1)
            rs[i]:=(ds[i]<0?0:ds[i])
        else
            rs[i]:=rs[i-1]+(ds[i]<0?0:ds[i])
        i++
    }
	
    i:=1
	j:=1
	while(j<=str_num){
		rnd:=Random(0, rs[dmax]-1)
		while(i<=dmax){
			if(rnd<rs[i])
				break
			i++
		}
		k:=1
		bOK:=true
		while(k<=j){
			if(ni[k]==i){
				bOK:=false
				break
			}
			k++
		}
		if(bOK==true){
			ni[j]:=i
			ds[i]:=-distance
			j++
			
		}
	}

	i:=1
	while(i<=str_num){
		test_strs[i]:=item_base[ni[i]]
		i:=i+1
	}
	fiwp:=FileOpen("i" fid ".txt", "w", "UTF-8")
	i:=1
	while(i<=dmax){
		ds[i]+=distance
		rnd:=Random(52,338)
        rnd*=193
		rnd+=ds[i]
		fiwp.WriteLine(rnd)
		i++
	}
	fiwp.close()
	MsgBox("测试时间为600秒，预备……","预备","0x40 T3")
}


ShowItem(level)
{
    global test_strs
    global test_str
    global TextAMaxNum
	global presskey_num_total
	global idea_presskey_num_total

    test_str:=test_strs[level]
	i:=1
	str_len:=StrLen(test_str)
	while(i<=str_len){		
		TextA[i].SetFont("cBlack s14", "黑体")
		TextA[i].Value:=substr(test_str,i,1)
		i++
	}
    while(i<=TextAMaxNum){
		TextA[i].SetFont("cBlack s14", "黑体")
		TextA[i].Value:=" "
		i++
    }
	TextInputNum.Value:=str_len_s_total "/" str_len_t_total+StrLen(test_str)
	idea_presskey_num_total:=idea_presskey_num_total+CalChKN(test_str)
	TextKeyNum.Value:=presskey_num_total[1]+presskey_num_total[2]
}

Check3char(str1,sp1,sl1,str2,sp2,sl2)
{
	i:=0
	while(sp1+i<=sl1 and sp2+i<=sl2){
		if(SubStr(str1,sp1+i,1)==SubStr(str2,sp2+i,1)){
			i:=i+1
			if(i>=3)
				return true
		}
		else{
			return false
		}
	}
	return false
}

btnStartTest(a,b)
{
	global isStart
	if(isStart==false)
		StartTest()
	return 1
}

StartTest()
{
	global test_level
	global test_max_level
	global test_str
	global test_strs
	global str_len_t_total
	global str_len_s_total
	global str_len_cs_total
	global correct_char_num_total
	global presskey_num_total
	global idea_presskey_num_total
	global usedTime
	global usedMaxTime

	SelectItem()

	test_level:=1
	
	NextItemBtn.Text:="下一条"
	str_len_t_total:=0
	str_len_s_total:=0
	str_len_cs_total:=0
	correct_char_num_total:=0
	presskey_num_total:=[0,0]
	idea_presskey_num_total:=0
	StuAnsEdit.Value:=""
	
    ShowItem(test_level)

	MouseClick "left",90,135,1,0
	mousemove 779,676,0
	ChangeUI(1)
	
	usedTime:=0
	TextTime.Value:=usedTime "秒"
	SetTimer(OnTimer,1000)
	return
}

btnNextItem(a,b)
{
	global isStart
	if(isStart==True)
		NextItem()
	return 1
}

CalChKN(str_stu_input)
{
	charsR:=["，","。","、","：","；","？","！","—","…","（","）","“","”","‘","’","《","》","·","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","0","1","2","3","4","5","6","7","8","9"]
	str_stu_chs_input:=str_stu_input
	loop charsR.Length
	{
		str_stu_chs_input:=StrReplace(str_stu_chs_input,charsR[A_Index])
	}
	return StrLen(str_stu_chs_input)
}

NextItem()
{
	global presskey_num_total
	global test_str
	global test_strs
	global test_level
	global test_max_level
	global str_len_t_total
	global str_len_s_total
	global str_len_cs_total
	global correct_char_num_total
	global StuAnsEdit
	global usedTime
	global usedMaxTime
	
	
	str_stu_input:=StuAnsEdit.Value
	str_len_cs:=CalChKN(str_stu_input)

	
	;检查错误
	str_len_t:=StrLen(test_str)
	str_len_s:=StrLen(str_stu_input)
	
	
	correct_char_num:=0
	error_char_num:=0

	ti:=1
	si:=1
	
	while(ti<=str_len_t and si<=str_len_s){
		char:=SubStr(test_str,ti,1)
		char_e:=SubStr(str_stu_input,si,1)
		if(char==char_e){
			correct_char_num++
			ti:=ti+1
			si:=si+1
		}
		else{
			error_char_num++
		
			isCompared:=false
			while(ti<=str_len_t-3 and si<=str_len_s-3){
				isCompared:=true
				isMatch_s:=false
				es_s:=0
				while(si+es_s<=str_len_s-3){
					if(Check3char(test_str,ti,str_len_t,str_stu_input,si+es_s,str_len_s)){
						isMatch_s:=true
						break
					}
					es_s++
				}
				
				isMatch_t:=false
				es_t:=0
				while(ti+es_t<=str_len_t-3){
					if(Check3char(test_str,ti+es_t,str_len_t,str_stu_input,si,str_len_s)){
						isMatch_t:=true
						break
					}
					es_t++
				}
				
				if(isMatch_s and isMatch_t){
					if(es_t<es_s){
						error_char_num++
						ti+=es_t
					}
					else if(es_t>es_s)
						si+=es_s
					else
						if(str_len_t<str_len_s)
							si+=es_s
						else
							ti+=es_t
					break
				}
				else
					if(isMatch_s){
						si+=es_s
						break
					}
					else if(isMatch_t){
						ti+=es_t
						break
					}
					else{
						ti++
						si++
					}
			}
			if(isCompared==false)
				break
		}
	}
	;检查错误结束
	
	str_len_t_total:=str_len_t_total+str_len_t
	str_len_s_total:=str_len_s_total+str_len_s
	str_len_cs_total:=str_len_cs_total+str_len_cs
	correct_char_num_total:=correct_char_num_total+correct_char_num
	
	if(test_level<test_max_level and usedTime<usedMaxTime){		
		;初始化
		StuAnsEdit.Value:=""
		MouseClick "left",90,135,1,0
		mousemove 779,676,0
		test_level:=test_level+1
		ShowItem(test_level)
		
		if(test_level==test_max_level){
			NextItemBtn.Text:="完成"
		}
	}
	else{ ;出结果
		GenerateResult()
	}
	
	return
}

GenerateResult()
{
	global presskey_num_total
	global idea_presskey_num_total
	global test_str
	global test_strs
	global str_len_t_total
	global str_len_s_total
	global str_len_cs_total
	global correct_char_num_total
	global test_level
	global test_max_level
	global usedTime
	global usedMaxTime

	SetTimer(OnTimer,0)
	str:=""
	if(test_level==test_max_level){
		if(str_len_t_total<str_len_s_total)
			correct_char_num_total:=correct_char_num_total-(str_len_s_total-str_len_t_total)
		correct_rate:=Round(correct_char_num_total/str_len_t_total,4)
		
		if(correct_rate>=0.99){
			key_per_word1:=Round((presskey_num_total[1]+presskey_num_total[2])/str_len_s_total,2)
			input_speed:=Round(60*str_len_s_total/usedTime,2)
			
			score:=Round(21.916*(1.571-ATan(1.5*(key_per_word1-2.5)))*(1.571+0.5915*ATan(0.05*(input_speed-50)))*correct_rate,1)
			if(score>100)
				score:=100
            str:="题目共：" str_len_t_total "字。" "`n正确输入：" correct_char_num_total "字。" "`n正确率：" Round(100*correct_rate,2) "% " "`n用时：" usedTime "秒" "`n平均：" input_speed "字/分钟" "`n击键：" presskey_num_total[1]+presskey_num_total[2] "次" "`n平均：" key_per_word1 "次/字。" "`n得分：" score

		}
		else{
			str:="输入正确率仅" Round(100*correct_rate,2) "%，不到99%，本次测试无效。"
		}
	}
	else
		str:="还有" test_max_level-test_level "题没开始做，本次测试无效。"
	MsgBox(str,"成绩")

    
															
	str:="`n" presskey_num_total[1] "`t" presskey_num_total[2] "`t" str_len_s_total "`t" usedTime
	FileAppend str, "udpn_input_data.txt"
	;完全初始化
	StartTest()
}



#hotif WinActive("输入速度测试-天津师范大学 信息技术在教学中的应用")

^v::
RButton::
{
;禁ctrl+v和鼠标右键，防粘贴
}

~LButton::
{
	OnKeyPress(2)
}

^Enter::
{
	btnNextItem(1,2)
}

!Enter::
{
	btnStartTest(1,2)
}

~q::
~w::
~e::
~r::
~t::
~y::
~u::
~i::
~o::
~p::
~a::
~s::
~d::
~f::
~g::
~h::
~j::
~k::
~l::
~z::
~x::
~c::
~v::
~b::
~n::
~m::
~,::
~.::
~?::
~!::
~'::
~"::
~;::
~+;::
~+-::
~/::
~\::
~(::
~)::
~+,::
~+.::
~+6::
{
	OnKeyPress(1)
}

~0::
~1::
~2::
~3::
~4::
~5::
~6::
~7::
~8::
~9::
~Numpad0::
~Numpad1::
~Numpad2::
~Numpad3::
~Numpad4::
~Numpad5::
~Numpad6::
~Numpad7::
~Numpad8::
~Numpad9::
~BackSpace::
~Space::
~Del::
~=::
~-::
~Left::
~Right::
~Up::
~Down::
{
	OnKeyPress(2)
}

mainFrame.OnEvent("Close", OnClose)
mainFrame.OnEvent("Escape", OnClose)
OnClose(a)
{
	ExitApp
}




