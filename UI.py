from tkinter import messagebox
from pyswip import *
#pip install git+https://github.com/yuce/pyswip@master#egg=pyswip
import tkinter as tk
import re
file_name = 'Assigment.pl'

def logic(type,SSS,BombsLocations)->list:
    prolog = Prolog()
    prolog.consult(file_name)
    init_uninformed = Functor("init_uninformed", 3)
    # init_informed = Functor("init_informed",3)
        
    Goal = Variable()
    if type=="uninformed":
        q = Query(init_uninformed(SSS,BombsLocations,Goal))

    OutputList = []

    while q.nextSolution():
        bytelist = Goal.get_value()
        stringlist=[x.decode('utf-8') for x in bytelist]
        OutputList.append(stringlist)
    q.closeQuery()
    return OutputList


class window():
    def __init__(self):
        self.SSS = []
        self.Results = []
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
        label.grid(row=0,column=0)

        label = tk.Label(self.Frame1,text="Bomb1:",font =('Arial',10),bg ="#A97171",foreground="white")
        label.grid(row=1,column=0)

        label = tk.Label(self.Frame1,text="Bomb2:",font =('Arial',10),bg ="#A97171",foreground="white")
        label.grid(row=2,column=0)
        #######################################
        self.entrySSS = tk.Entry(self.Frame1,border=0)
        self.entrySSS.grid(row=0,column=1)

        self.entryB1 = tk.Entry(self.Frame1,border=0)
        self.entryB1.grid(row=1,column=1)

        self.entryB2 = tk.Entry(self.Frame1,border=0)
        self.entryB2.grid(row=2,column=1)
        #######################################
        buttonUninformed = tk.Button(self.Frame1,text="uninformed",border=0,bg="#7B6585",foreground="white",width=15,command=self.Uninformed)
        buttonUninformed.grid(row = 0, column=3)

        buttonNext = tk.Button(self.Frame1,text="Next",border=0,bg="#7B6585",foreground="white",width=15,command=self.Update)
        buttonNext.grid(row = 1, column=3)

        buttonInformed = tk.Button(self.Frame1,text="informed",border=0,bg="#7B6585",foreground="white",width=15)
        buttonInformed.grid(row = 2, column=3)

        self.Frame1.pack(fill="both",side="top")


        self.Frame2 = tk.Frame(self.window,bg="#D9D9D9")
        self.Frame2.pack(fill="both",expand=True,side="bottom")

        self.window.mainloop()
        
        
    def get_Data(self,s):
        try:
            i = 0
            while s[i]==' ':
                s=s[i+1:]
            my_list = [int(x) for x in re.split(r"\D+", s)]
            print(my_list)
            if(len(my_list)<2 or len(my_list)>2 or my_list[0]<1 or my_list[1]<1):
                raise
        except:
            messagebox.showerror("Error", s+" is not allowed")
            return False
        return my_list

    def Uninformed(self):
        s = self.entrySSS.get()
        self.SSS = self.get_Data(s)
        s = self.entryB1.get()
        B1 = self.get_Data(s)
        s = self.entryB2.get()
        B2 = self.get_Data(s)
        
        if self.SSS==False or B1==False or B2==False:
            return
        
        BombsLocations = [B1,B2]
        Results = logic("uninformed",self.SSS,BombsLocations)
        print(Results)
        self.Update()
    
    def Update(self):
        square = tk.Frame(self.Frame2,bg="#623737",width=50,height=50)
        bomb = tk.Frame(self.Frame2,bg="black",width=50,height=50)
        domino = tk.Frame(self.Frame2,bg="while",width=50,height=50)
        for i in range(self.SSS[1]):
            self.Frame2.columnconfigure(i,weight=1)
        
        return
        

if __name__=="__main__":
    obj = window()
    