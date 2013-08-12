module main;

import list, std.stdio, std.random, std.datetime;



int main(string[] args)
{
    Random generator;
    auto fout = File("array.txt","w");
    for(auto i=0; i<64_000; ++i)
    {
        int n = generator.front%100_000;
        fout.writefln("%d",n);
        generator.popFront();
    }
    fout.close;
    auto fin = File("array.txt","r");
    auto list=new List!int;
    while(!fin.eof)
    {
        int n;
        fin.readf("%d ",&n);
        list.pushBack(n);
    }
    fin.close;

    auto tic = Clock.currSystemTick;
    sortByInsertion(list);
    auto toc = Clock.currSystemTick;
    auto duration = toc - tic;
    writeln("unsorted insertion");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");

    tic = Clock.currSystemTick;
    sortByInsertion(list);
    toc = Clock.currSystemTick;
    duration = toc - tic;
    writeln("sorted inserrtion");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");

    list.clear();
    auto fin1= File("array.txt","r");
    while(!fin1.eof)
    {
        uint n;
        fin1.readf("%d ",&n);
        list.pushBack(n);
    }
    fin1.close;

   // list.print();
    tic = Clock.currSystemTick;
    sortByMerge(list);
    toc = Clock.currSystemTick;
    duration = toc - tic;
    writeln("unsorted merged");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");

    //list.print();
    tic = Clock.currSystemTick;
    sortByMerge(list);
    toc = Clock.currSystemTick;
    duration = toc - tic;
    writeln("sorted merged");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");

    list.clear();
    auto fin2= File("array.txt","r");
    while(!fin2.eof)
    {
        uint n;
        fin2.readf("%d ",&n);
        list.pushBack(n);
    }
    fin2.close;

    //list.print();
    tic = Clock.currSystemTick;
    sortByTimsort(list);
    toc = Clock.currSystemTick;
    duration = toc - tic;
    writeln("unsorted timsort");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");

    //list.print();
    tic = Clock.currSystemTick;
    sortByTimsort(list);
    toc = Clock.currSystemTick;
    duration = toc - tic;
    writeln("sorted timsort");
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");
    /*while(!list.isEmpty)
    {
        write(list.onFront," ");
        list.popFront();
    }*/
    return 0;
}
