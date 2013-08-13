module main;

import list, std.stdio, std.random, std.datetime, std.format,std.conv;

int main(string[] args)
{
    Random generator;
    string[] filesNames = new string[1];
    filesNames[0] = "unsorted.txt";
    ++filesNames.length;
    auto fout = File(filesNames[0],"w");
    auto immutable size =2_000;
    for(auto i=0; i<size; ++i)
    {
        int n = generator.front%100_000;
        fout.writefln("%5d %5d",n,i);
        generator.popFront();
    }
    fout.close;



    {
        auto list=new List!Pair;
        loadList(list,"unsorted.txt",size);


        sortByMerge(list);
        filesNames[1] = "sorted.txt";
        list.print(filesNames[1]);


        int[] cases=[10,100,1000,20_000];
        foreach(c; cases)
        {
            writeln("size", list.size);
            writeln("ref list "~to!string(list));
            writeln("is ref null "~to!string(list is null));
            list.verify();
            shuffle(list,c,size);
            writeln("after shuffle");
            //writeln("size", list.size);
            ++filesNames.length;
            filesNames[filesNames.length-1] =  format("shuffled_%d.txt",c);

            //list.print(filesNames[filesNames.length-1]);

            writeln("before clear");
            list.clear();
            writeln("after clear");
            //list = new List!Pair;

            writeln("before load");
            loadList(list,"sorted.txt",size);
            writeln("after load");
        }

    }



    /*  test(SortType.Insertion,"insertion");

      //*
      auto fetalon = File("etalon.txt","w");
       list.print(&fetalon);
       fetalon.close();//


      test(SortType.Merge,"merged");
      test(SortType.Quick,"quick");
      test(SortType.Timsort,"timsort");*/

    SortType[] sortType=[SortType.Insertion, SortType.Merge, SortType.Quick, SortType.Timsort];

    foreach(e; sortType)
    {
        foreach(f; filesNames)
        {
            test(e,f,size);
        }
    }

    return 0;
}

enum SortType {Insertion, Merge, Quick, Timsort}
//void function(Type)(List!Type) Srtf;
void test(SortType sortType, string fileName,int size)
{
    auto list=new List!Pair;
    loadList(list,fileName,size);

    TickDuration tic ,toc;
    string name;
    // mixin(srtf~"(list)");
    switch(sortType)
    {
    case SortType.Insertion:
        tic= Clock.currSystemTick;
        sortByInsertion(list);
        toc = Clock.currSystemTick;
        name="insertionSort";
        break;
    case SortType.Merge:
        tic= Clock.currSystemTick;
        sortByMerge(list);
        toc = Clock.currSystemTick;
        name="mergeSort";
        break;
    case SortType.Quick:
        tic= Clock.currSystemTick;
        sortByQuickDPP(list);
        toc = Clock.currSystemTick;
        name="quickSort";
        break;
    case SortType.Timsort:
        tic= Clock.currSystemTick;
        sortByTimsort(list);
        toc = Clock.currSystemTick;
        name="timSort";
        break;
    default:
        assert(false,"non allowed type of sort");
    }

    auto duration = toc - tic;
    writeln(fileName ~ " " ~ name);
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");
}

struct Pair
{
    int first, second;
    this(int first, int second)
    {
        this.first=first;
        this.second=second;
    }
    int opCmp(Pair rhs)
    {
        return this.first-rhs.first;
    }

    string toString()
    {
        return format("%5d %5d",first,second);
    }
}

void shuffle(Type)(List!Type list, int amount, int size)
{
    Random generator;
    for(auto i=0; i<amount; ++i)
    {
        int m = generator.front%size;
        generator.popFront();
        int n = generator.front%size;
        generator.popFront();
        //list.swap(m,n);
    }
}

void loadList(Type)(List!Type list,string fileName, int size)
{
    if(!list.isEmpty)
        list.clear;
    auto fin = File(fileName,"r");
    for(auto c=0; c<size; ++c)
    {
        int n,i;
        fin.readf(" %d %d",&n,&i);
        list.pushBack(Pair(n,i));
    }
    fin.close;
}
