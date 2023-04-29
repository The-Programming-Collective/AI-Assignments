from tkinter import messagebox
from pyswip import *
#pip install git+https://github.com/yuce/pyswip@master#egg=pyswip
import tkinter as tk
import re

MaxDominos = -1

def logic(type,SSS,BombsLocations)->list:
    global MaxDominos
    init_uninformed = Functor("init_uninformed", 3)
    init_informed = Functor("init_informed",3)

    prolog = Prolog()
    prolog.consult("uninformed.pl")
    prolog.consult("informed.pl")
    Goal = Variable()
    
    if type=="uninformed":
        q = Query(init_uninformed(SSS,BombsLocations,Goal))
        MaxDominos = -1

        
    elif type=="informed":
        q = Query(init_informed(SSS,BombsLocations,Goal))
        
    OutputList = []

    while q.nextSolution():
        bytelist = Goal.get_value()[0]
        stringlist=[x.decode('utf-8') for x in bytelist]
        OutputList.append(stringlist)
    q.closeQuery()

    if type=="informed":
        x = list(prolog.query("get_numDominos_variable(Value)"))
        MaxDominos = x[0]["Value"]

    
    return OutputList


class window():
    def __init__(self):
        self.SSS = []
        self.B1 = []
        self.B2 = []
        self.Results = []
        self.currResult=0
        # Create the window
        self.window = tk.Tk()
        self.window.title("Prolog")
        self.window.geometry("500x400")
        self.window.configure(bg = "#D9D9D9")

        self.Frame1 = tk.Frame(self.window,bg="#A97171",pady=10)
        self.Frame1.columnconfigure(0,weight=1)
        self.Frame1.columnconfigure(1,weight=1)
        self.Frame1.columnconfigure(2,weight=1)
        #######################################
        label = tk.Label(self.Frame1,text="State space:",font =('Arial',10),bg ="#A97171",foreground="white")
        label.grid(row=0,column=0,sticky="w",padx=10)

        label = tk.Label(self.Frame1,text="Bomb1:",font =('Arial',10),bg ="#A97171",foreground="white")
        label.grid(row=1,column=0,sticky="w",padx=10)

        label = tk.Label(self.Frame1,text="Bomb2:",font =('Arial',10),bg ="#A97171",foreground="white")
        label.grid(row=2,column=0,sticky="w",padx=10)
        #######################################
        self.entrySSS = tk.Entry(self.Frame1,border=0)
        self.entrySSS.grid(row=0,column=1)

        self.entryB1 = tk.Entry(self.Frame1,border=0)
        self.entryB1.grid(row=1,column=1)

        self.entryB2 = tk.Entry(self.Frame1,border=0)
        self.entryB2.grid(row=2,column=1)
        #######################################
        buttonUninformed = tk.Button(self.Frame1,text="uninformed",border=0,bg="#7B6585",foreground="white",width=15,command=lambda :self.search("uninformed"))
        buttonUninformed.grid(row = 0, column=3,padx=10)

        buttonNext = tk.Button(self.Frame1,text="Next",border=0,bg="#7B6585",foreground="white",width=15,command=self.Update)
        buttonNext.grid(row = 1, column=3,padx=10)

        buttonInformed = tk.Button(self.Frame1,text="informed",border=0,bg="#7B6585",foreground="white",width=15,command=lambda :self.search("informed"))
        buttonInformed.grid(row = 2, column=3,padx=10)

        self.Frame1.pack(fill="both",side="top")

        self.Frame2 = tk.Frame(self.window,bg="#D9D9D9")
        self.Frame2.pack(expand=True,side="bottom")
        
        self.Frame3 = tk.Frame(self.window,bg="#D9D9D9")
        self.Frame3.pack(expand=True,side="bottom")

        self.window.mainloop()
        
    def parse_data(self,s):
        s = s.get()
        
        i = 0
        while s[i]==' ':
            s=s[i+1:]
            
        my_list = [int(x) for x in re.split(r"\D+", s)]
        
        if(len(my_list)<2 or len(my_list)>2 or my_list[0]<1 or my_list[1]<1):
            raise
        
        return my_list
        
    def get_Data(self):
        try: 
            self.currResult=0
            
            self.SSS = self.parse_data(self.entrySSS)
            self.B1 = self.parse_data(self.entryB1)
            self.B2= self.parse_data(self.entryB2)
            
            if( self.B1 ==  self.B2):
                raise

        except:
            messagebox.showerror("Error","check entered data")
            return False
        
        return True


    def search(self,s):
        if not self.get_Data():
            return
        
        bombList=[self.B1,self.B2]
        self.Results = logic(s,self.SSS,bombList)
        
        if len(self.Results)==0:
            messagebox.showerror("Error","check entered data")
            return
        
        self.Update()
        
        
    def reset(self,frame):
        for item in frame.winfo_children():
            item.destroy()
    
    def Update(self):
        if self.currResult==len(self.Results):
            messagebox.showinfo("info","this is the last solution")
            return
        
        if len(self.Results)==0:
            messagebox.showwarning("warning","no solutions found")
            return
        
        self.reset(self.Frame2)
        self.reset(self.Frame3)

        # square = tk.Frame(self.Frame2,bg="#623737",width=50,height=50)
        # bomb = tk.Frame(self.Frame2,bg="black",width=50,height=50)
        # domino = tk.Frame(self.Frame2,bg="white",width=50,height=50)
        for i in range(self.SSS[1]):
            self.Frame2.columnconfigure(i,weight=1)
            
        for i in range(self.SSS[0]):
            for j in range(self.SSS[1]):
                
                curr = self.Results[self.currResult][(i*self.SSS[1])+j]
                
                if curr == '!' : 
                    continue
                
                square = tk.Frame(self.Frame2,bg="#623737",width=50,height=50)
                square.grid(column=j,row=i,pady=5,padx=5)
                
                if curr=='X':
                    error = tk.Frame(square,bg="red",width=30,height=30)
                    error.pack(padx=10,pady=10)
                
                #lighter
                elif curr=='V':
                    domino = tk.Frame(square,bg="#DEDEDE",width=30,height=30)
                    domino.pack(side='bottom', padx=10, pady=10 , fill="none")
                
                #darker
                elif curr=='H':
                    domino = tk.Frame(square,bg="#6B6B6B",width=30,height=30)
                    domino.pack(side='bottom', padx=10, pady=10 , fill="none")

        if MaxDominos>-1:
            label = tk.Label(self.Frame3,text="Maximum number of dominos: {}".format(MaxDominos),bg="#D9D9D9",foreground="#623737",font="Arial 15 bold")
            label.pack()
        
        label = tk.Label(self.Frame3,text="Current solution: {}".format(self.currResult+1),bg="#D9D9D9",foreground="#623737",font="Arial 15 bold")
        label.pack()
        self.currResult = self.currResult+1
        return
        

if __name__=="__main__":
    obj = window()
    