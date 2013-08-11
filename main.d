module main;

import list, std.stdio;



int main(string[] args)
{
    auto list=new List!int;
    list.pushBack(4);
    list.pushBack(3);
    list.pushBack(5);
    list.pushBack(5);
    list.pushBack(-7);
    list.pushBack(8);
    sortByInsertion(list);
    while(!list.isEmpty)
    {
        writeln(list.onFront);
        list.popFront();
    }
    return 0;
}
