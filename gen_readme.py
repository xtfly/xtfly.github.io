#!/bin/python3
import glob
import os
from datetime import datetime

def main():
    cdir = os.path.normpath(os.path.dirname(__file__))
    sdir = cdir + '/content/post/**/*.md'
    files = glob.glob(sdir, recursive=True)
    
    blogs = [get_meta(file, cdir) for file in files]
    blogs = sorted(blogs, key=lambda x: x[0], reverse=True)
    
    rd_file = cdir + '/README.md'
    write_to_file(rd_file, blogs)
        

def get_meta(file: str, cdir: str):
    title, date = None, None
    with open(file, "r") as of:
        line = of.readline()
        while title is None or date is None:
            if line.startswith("title"):
                title = line.split(":")[1].strip()[1:-1]
            if line.startswith("date"):
                date = line.split(":")[1].strip()[1:-1]
                date = datetime.strptime(date, '%Y-%m-%d')
            line = of.readline()
    return date, title, file[len(cdir)+1:]


def write_to_file(file: str, blogs):
    with open(file, "w+") as of:
        of.writelines(['一指流沙，程序年华\r\n', '--------------\r\n'])
        year = None
        for x in blogs:
            date, title, file = x
            if date.year != year:
                year = date.year
                of.write('\r\n')
                of.write(f'# {year}\r\n')
            of.write(f'  - [{date.strftime("%m-%d")}][{title}]({file})\r\n')
                

if __name__ == "__main__":
    main()