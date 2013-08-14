module main;

import list, std.stdio, std.random, std.datetime, std.format,std.conv,std.string;

int main(string[] args)
{
    Random generator;
    string[] filesNames = new string[1];
    filesNames[$-1] = "unsorted.txt";
    //++filesNames.length;
    auto fout = File(filesNames[0],"w");
    auto immutable size =32_000;
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
        string sorted = "sorted.txt";
        list.print(sorted);


        int[] cases=[20_000,10_000,5_000,4_000,3_000,2_000,1_000,500,400,300,200,100,60,40,20,10,9,8,7,6,5,4,3,2,1,0];
        foreach(c; cases)
        {
            shuffle(list,c,size);
            ++filesNames.length;
            filesNames[$-1] =  format("shuffled_%d.txt",c);
            list.print(filesNames[$-1]);
            list.clear();
            loadList(list,sorted,size);
        }
        ++filesNames.length;
        filesNames[$-1] = sorted;
    }



    /*  test(SortType.Insertion,"insertion");

      //*
      auto fetalon = File("etalon.txt","w");
       list.print(&fetalon);
       fetalon.close();//


      test(SortType.Merge,"merged");
      test(SortType.Quick,"quick");
      test(SortType.Timsort,"timsort");*/

    SortType[] sortType=[/+SortType.Insertion,+/ SortType.Merge, SortType.Quick, SortType.Timsort];
    string[] logsNames=["ins.log","mrg.log","qck.log","tim.log"];

    //auto log=File("all.log");
    foreach(e; sortType)
    {
        File log;
        log.open(logsNames[e],"w");
        assert(log.isOpen);
        foreach(f; filesNames)
        {
            test(e,f,size,&log);
        }
        log.close();
        writeln();
    }
    //log.close();

    return 0;
}

enum SortType {Insertion, Merge, Quick, Timsort}

void test(SortType sortType, string fileName,int size,File* log=null)
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
    writeln(name ~ "\t\t" ~ fileName);
    writeln(duration.usecs/1000_000,"  sec ",(duration.usecs%1000_000)/1000," msec ",duration.usecs%1000," usec");
    if(log && indexOf(fileName,"shuffled")!=-1)
        log.writefln("%6d %6d",to!int(removechars(fileName,"^0-9")),duration.usecs);
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
        list.swap(m,n);
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
