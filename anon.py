import os
from tkinter import *
from subprocess import Popen, PIPE, STDOUT
import sys
from getpass import getpass
from threading  import Thread
import re

frame = None
consoleOutput = None
inputSandbox = None
inputUsername = None
inputPassword = None
inputScriptFile = None
inputExec = None

def handleProcessSandboxList(script, name):
    for sandbox in re.split('[ ,]+', inputSandbox.get()):
        handleProcess(script, sandbox, name)

def handleProcess(script, sandbox, name):
    p = Popen("./executeApex.sh " + inputUsername.get() + " " + inputPassword.get() + " scripts/" + script + " " + sandbox, shell=True, bufsize=-1, stdout=PIPE, stderr=PIPE)
    tSplit = Thread(target=handleProcessSplitter, args=[p, name + " . " + sandbox])
    tSplit.daemon = True
    tSplit.start()

def handleProcessSplitter(p, name):
    tOut = Thread(target=showOutput, args=[p.stdout, "blue", True])
    tErr = Thread(target=showOutput, args=[p.stderr, "red"])
    tOut.daemon = True
    tErr.daemon = True
    tOut.start()
    tErr.start()
    tOut.join()
    tErr.join()
    addConsoleOutputLine("\nEND: " + name + "\n", "black")

def showOutput(out, color, filterDebug=False):
    for line in iter(out.readline, b''):
        if (not filterDebug) or isDebug(line):
            addConsoleOutputLine(line, color)
    out.close()

def isDebug(line):
    return "|DEBUG|" in str(line)

def addConsoleOutputLine(line, color):
    global consoleOutput, frame
    consoleOutput.insert(END, line, color)
    consoleOutput.see(END)
    frame.update_idletasks()

def clearOutput():
    global consoleOutput, frame
    consoleOutput.delete('1.0', END)
    consoleOutput.see(END)
    frame.update_idletasks()

def fillInputExec(script):
    global inputExec
    file = open("scripts/" + script, "r")
    fill = file.read()
    file.close()
    inputExec.delete('1.0', END)
    inputExec.insert(END, fill)

def runScript():
    global inputScriptFile
    # handleProcessList(inputScriptFile.get(), "Run Script")
    handleProcess(inputScriptFile.get(), inputSandbox.get(), "Run Script")

def runAnon():
    global inputExec
    saveScript("tempInlineScript")
    # handleProcessList("tempInlineScript", "Run Anon")
    handleProcess("tempInlineScript", inputSandbox.get(), "Run Anon")

def listScripts():
    for script in os.listdir("scripts"):
        addConsoleOutputLine(script + "\n", "black")

def viewScript():
    fillInputExec(inputScriptFile.get())

def saveOpenScript():
    saveScript(inputScriptFile.get())

def saveScript(scriptFile):
    global inputExec
    script = inputExec.get('1.0', END)
    file = open("scripts/" + scriptFile, "w")
    file.write(script)
    file.close()

def createUI():
    global frame, consoleOutput, inputSandbox, inputUsername, inputPassword, inputExec, inputScriptFile
    root = Tk()
    root.wm_title("\"we makin' stuff better\" - Ben Franklin")
    root.resizable(False, False)
    frame = Frame(root)
    frame.grid(row=0, column=0, pady=5)
    buttonFrame = Frame(root)
    buttonFrame.grid(row=1, column=0)
    bframe = Frame(root)
    bframe.grid(row=2, column=0)
    
    inputWidth = 20
    width = 20
    buttonWidth = 10
    
    Label(frame, text="username: ").grid(row=0, column=0, sticky='e')
    inputUsername = Entry(frame, width=inputWidth)
    inputUsername.insert(0, sys.argv[1])
    inputUsername.grid(row=0, column=1, sticky='ew')
    
    Label(frame, text="pasword: ").grid(row=0, column=2, sticky='e')
    inputPassword = Entry(frame, show="*", width=inputWidth)
    inputPassword.insert(0, getpass("password: "))
    inputPassword.grid(row=0, column=3, sticky='ew')
    
    Label(frame, text="environment: ").grid(row=1, column=0, sticky='e')
    inputSandbox = Entry(frame, width=inputWidth)
    inputSandbox.insert(0, "pladev")
    inputSandbox.grid(row=1, column=1, sticky='ew')
    
    Label(frame, text="script: ").grid(row=1, column=2, sticky='e')
    inputScriptFile = Entry(frame, width=inputWidth)
    inputScriptFile.insert(0, "")
    inputScriptFile.grid(row=1, column=3, sticky='ew')
    
    Button(buttonFrame, text="Run Anon", command=runAnon, width=buttonWidth).grid(row=2, column=0, sticky='ew')
    Button(buttonFrame, text="Run Script", command=runScript, width=buttonWidth).grid(row=2, column=1, sticky='ew')
    Button(buttonFrame, text="Clear Output", command=clearOutput, width=buttonWidth).grid(row=2, column=2, sticky='ew')
    Button(buttonFrame, text="List Scripts", command=listScripts, width=buttonWidth).grid(row=2, column=3, sticky='ew')
    Button(buttonFrame, text="View Script", command=viewScript, width=buttonWidth).grid(row=2, column=4, sticky='ew')
    Button(buttonFrame, text="Save Script", command=saveOpenScript, width=buttonWidth).grid(row=2, column=5, sticky='ew')
    
    inputExec = Text(bframe)
    inputExec.grid(row=0, column=0, sticky='ew')
    inputExec.tag_config("black", foreground="black")
    inputExec.tag_config("red", foreground="red")
    inputExec.tag_config("blue", foreground="blue")
    fillInputExec("tempInlineScript")
  
    scrollbar = Scrollbar(bframe, command=inputExec.yview)
    scrollbar.grid(row=0, column=1, sticky='nsew')
    inputExec['yscrollcommand'] = scrollbar.set
    
    consoleOutput = Text(bframe)
    consoleOutput.grid(row=1, column=0, sticky='ew')
    consoleOutput.tag_config("black", foreground="black")
    consoleOutput.tag_config("red", foreground="red")
    consoleOutput.tag_config("blue", foreground="blue")
    
    scrollbar = Scrollbar(bframe, command=consoleOutput.yview)
    scrollbar.grid(row=1, column=1, sticky='nsew')
    consoleOutput['yscrollcommand'] = scrollbar.set
     
    root.lift()
    os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
    root.mainloop()

createUI()