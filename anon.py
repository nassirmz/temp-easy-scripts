from os import system
from tkinter import *
from subprocess import Popen, PIPE, STDOUT
import sys
from getpass import getpass
from threading  import Thread

frame = None
consoleOutput = None
inputSandbox = None
inputUsername = None
inputPassword = None
inputExec = None

# todo: optinally replace tempInlineScript with entry param

def handleProcess(command, name):
    p = Popen(command + " " + inputSandbox.get() + " tempInlineScript " + inputUsername.get() + " " + inputPassword.get(), shell=True, bufsize=-1, stdout=PIPE, stderr=PIPE)
    tSplit = Thread(target=handleProcessSplitter, args=[p, name])
    tSplit.daemon = True
    tSplit.start()

def handleProcessSplitter(p, name):
    tOut = Thread(target=showOutput, args=[p.stdout, "blue"])
    tErr = Thread(target=showOutput, args=[p.stderr, "red"])
    tOut.daemon = True
    tErr.daemon = True
    tOut.start()
    tErr.start()
    tOut.join()
    tErr.join()
    addConsoleOutputLine("\nEND: " + name + "\n", "black")

def showOutput(out, color):
    for line in iter(out.readline, b''):
        addConsoleOutputLine(line, color)
    out.close()

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

def runAnon():
    global inputExec, outputExec
    script = inputExec.get('1.0', END)
    file = open("tempInlineScript", "w")
    file.write(script)
    file.close()
    handleProcess("./executeApex.sh", "Run Anon")

def createUI():
    global frame, consoleOutput, inputSandbox, inputUsername, inputPassword, inputExec
    root = Tk()
    root.wm_title("\"we makin' stuff better\" - Ben Franklin")
    root.resizable(False, False)
    frame = Frame(root)
    frame.grid(row=0, column=0, pady=5)
    bframe = Frame(root)
    bframe.grid(row=1, column=0)
    
    inputWidth = 20
    width = 20
    buttonWidth = 15
    
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
    
    Button(bframe, text="Run Anon", command=runAnon, width=buttonWidth).grid(row=2, column=0, sticky='ew')
    Button(bframe, text="Clear Output", command=clearOutput, width=buttonWidth).grid(row=2, column=1, sticky='ew')
    
    inputExec = Text(bframe, width=width*4)
    inputExec.grid(row=3, column=0, columnspan=4, sticky='ew')
    inputExec.tag_config("black", foreground="black")
    inputExec.tag_config("red", foreground="red")
    inputExec.tag_config("blue", foreground="blue")
  
    scrollbar = Scrollbar(bframe, command=inputExec.yview)
    scrollbar.grid(row=3, column=4, sticky='nsew')
    inputExec['yscrollcommand'] = scrollbar.set
    
    consoleOutput = Text(bframe, width=width*4)
    consoleOutput.grid(row=4, column=0, columnspan=4, sticky='ew')
    consoleOutput.tag_config("black", foreground="black")
    consoleOutput.tag_config("red", foreground="red")
    consoleOutput.tag_config("blue", foreground="blue")
    
    scrollbar = Scrollbar(bframe, command=consoleOutput.yview)
    scrollbar.grid(row=4, column=4, sticky='nsew')
    consoleOutput['yscrollcommand'] = scrollbar.set
     
    root.lift()
    system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
    root.mainloop()

createUI()