import std.stdio;

class ListException: Exception
{
    this()
    {
        super("ListException");
    }
}

private struct Node(Type)
{
    Type datum;
    Node* left,
          right;

    this(Type datum)
    {
        this.datum=datum;
    }
    ~this()
    {
        datum=Type.init;
        left=null;
        right=null;
    }
}

class List(Type)
{

    private Node!Type *beg,
            end;
    int size;

    this() nothrow {}

    nothrow ~this ()
    {
        clear();
    }



    void pushBack(Type datum)
    {
        Node!Type *p=new Node!Type(datum);
        pushBack(p);
    }

    private void pushBack(Node!Type* p) nothrow
    {
        if(p)
        {
            p.left=end;
            if(end)
            {
                end.right=p;
            }
            else
            {
                beg=p;
            }
            end=p;
            p=null;
            ++size;
        }
    }

    void pushFront(Type datum)
    {
        Node!Type *p=new Node!Type(datum);
        pushFront(p);
    }

    private void pushFront(Node!Type* p) nothrow
    {
        if(p)
        {
            p.right=beg;
            if(beg)
            {
                beg.left=p;
            }
            else
            {
                end=p;
            }
            beg=p;
            p=null;
            ++size;
        }
    }

    private Node!Type* popNodeBack()
    {
        if(!isEmpty)
        {
            auto p=end;
            end=end.left;
            if(!end)
                beg=null;
            --size;
            p.left=null;
            return p;
        }
        return null;
    }

    void popBack() nothrow
    {
        if(!isEmpty)
        {
            Node!Type* p=end;
            end=end.left;
            if(!end)
                beg=null;
            p=null;
        }
        --size;
    }

    private Node!Type* popNodeFront()
    {
        if(!isEmpty)
        {
            auto p=beg;
            beg=beg.right;
            if(!beg)
                end=null;
            --size;
            p.right=null;
            return p;
        }
        return null;
    }

    void popFront() nothrow
    {
        if(!isEmpty)
            deleteForward();
    }

    void clear() nothrow
    {
        while(!isEmpty)
            deleteForward();
    }

    private void deleteForward() nothrow
    {
        Node!Type* p=beg;
        beg=beg.right;
        if(!beg)
            end=null;
        p=null;
        --size;
    }

    @property Type onBack() const
    {
        if(!isEmpty)
            return end.datum;
        else throw new ListException;
    }

    @property Type onFront() const
    {
        if(!isEmpty)
            return beg.datum;
        else throw new ListException;
    }

    @property bool isEmpty() const nothrow
    {
        return !beg && !end;
    }

    void print() /+nothrow+/
    {
        writeln("list:");
        if(this.isEmpty)
        {
            writeln("empty");
        }
        else
        {
            Node!Type* p=beg;
            while(p)
            {
                write(p.datum," ");
                p=p.right;
            }
            writeln();
            /* p=end;
             while(p)
             {
                 write(p.datum," ");
                 p=p.left;
             }
             writeln();*/
        }
    }

    /* private ref List!Type cutSubList(Node!Type* p, Node!Type* q)
     {

     }*/
}

void sortByInsertion(Type)(List!Type list)
{
    if(!list.isEmpty)
    {
        Node!Type* prebeg=new Node!Type(Type.init),
        postend= new Node!Type(Type.init);
        prebeg.right=list.beg;
        list.beg.left=prebeg;
        postend.left=list.end;
        list.end.right=postend;
        Node!Type* p=list.beg.right;
        while(p!=postend)
        {
            Node!Type* q=p.left;
            while(q!=prebeg && p.datum<q.datum)
                q=q.left;
            if(q.right!=p)
            {
                p.left.right=p.right;
                p.right.left=p.left;
                p.left=q;
                p.right=q.right;
                p.left.right=p;
                p.right.left=p;
            }
            p=p.right;
        }
        list.beg=prebeg.right;
        list.end=postend.left;
        list.beg.left=null;
        list.end.right=null;

        //prebeg.~this();
        //postbeg.~this();
        prebeg=null;
        postend=null;
    }
}

void sortByMerge(Type)(List!Type list)
{
    if(!list.isEmpty)
    {
        auto part = new List!Type;
        split(list,part);
        if(list.size>1)
            sortByMerge(list);
        if(part.size>1)
            sortByMerge(part);
        merge(list,part);
        part = null;
    }
}

private void connect(Type)(List!Type list, List!Type part)
{
    list.end.right = part.beg;
    part.beg.left = list.end;
    list.size += part.size;
    list.end = part.end;
    part.beg = null;
    part.end = null;
    part.size = 0;
}

private void split(Type)(List!Type list, List!Type part)
{
    //list.print();
    bool direction=false;
    Node!Type* p=list.beg, q=list.end;
    int pSize=1,qSize=1;
    // writeln("p ",p.datum," q ",q.datum);
    while(p.right!=q)
    {
        if(direction)
        {
            p=p.right;
            ++pSize;
        }
        else
        {
            q=q.left;
            ++qSize;
        }
        //  writeln("p ",p.datum," q ",q.datum);
        direction=!direction;
    }
    //writeln("list ",list.size);
    // writeln("p+q ",pSize+qSize);
    assert(list.size == pSize+qSize);
    part.beg=q;
    part.end=list.end;
    list.end=p;
    p.right=null;
    q.left=null;
    list.size=pSize;
    part.size=qSize;
    p=null;
    q=null;
}

private void merge(Type)(List!Type list, List!Type part)
{
    auto temp= new List!Type;
    temp.beg=list.beg;
    temp.end=list.end;
    temp.size=list.size;
    list.beg=null;
    list.end=null;
    list.size=0;
    while(!temp.isEmpty && !part.isEmpty)
    {
        if(temp.onFront <= part.onFront)
        {
            list.pushBack(temp.popNodeFront);
        }
        else
        {
            list.pushBack(part.popNodeFront);
        }
    }
    if(!temp.isEmpty)
    {
        connect(list,temp);
    }
    if(!part.isEmpty)
    {
        connect(list,part);
    }
    temp = null;
}

void sortByTimsort(Type)(List!Type list)
{
    immutable uint minrunTreshold=64;
    uint lengthMinrun(uint size)
    {
        uint flag = 0;
        while(size>=minrunTreshold)
        {
            flag |= size & 1;
            size >>= 1;
        }
        return size+flag;
    }

    uint minrun = lengthMinrun(list.size);
    writeln("minrun = ", minrun);
    List!Type[] stack=new List!Type[list.size/minrun+1];
    int top = 0;

    //split on run
    List!Type run;
    while(!list.isEmpty)
    {
        run = new List!Type;
        if(list.size>1)
        {
            Node!Type*  q = list.beg.right;
            uint size = 2;
            if(list.beg.datum<=q.datum)
            {
                // non descdending order
                while(q!=list.end && q.datum<=q.right.datum)
                {
                    q=q.right;
                    ++size;
                }
                beisen(run,q,size,list);
            }
            else
            {
                // descending oreder
                while(q!=list.end && q.datum > q.right.datum)
                {
                    q=q.right;
                    ++size;
                }
                beisen(run,q,size,list);
                reverse(run);
            }
        }
        else
        {
            run = list;
            //list = null;
        }

        if(!list.isEmpty && run.size<minrun)
        {
            List!Type apendix = new List!Type;
            Node!Type* q=list.beg;
            uint apendixSize =minrun-run.size;
            uint size = 1;
            for(int i=0; q!=list.end && i<apendixSize; ++i)
            {
                q=q.right;
                ++size;
            }
            beisen(apendix,q,size,list);
            connect(run,apendix);
            sortByInsertion(run);
            apendix = null;
        }


        stack[top++]=run;
        writeln("top = ",top);
        writefln("run =%d",run.size);
        run = null;

        // merging




        bool a,b;
        while((top>=3 && (stack[top-3].size <= stack[top-2].size+stack[top-1].size))
                || (top>=2 && (stack[top-2].size <= stack[top-1].size)))
        {
            /*writeln("top = ", top);
            writeln("stack:");
            for(int i=0; i<top; ++i)
                writef("%3d ", stack[i].size);
            writeln();*/
            if(top>=3 && (stack[top-3].size <= stack[top-2].size+stack[top-1].size))
            {
                if(stack[top-3].size<=stack[top-1].size)
                {
                    merge(stack[top - 3],stack[top - 2]);
                    stack[top - 2] = stack[top - 1];
                    stack[top - 1] = null;
                    --top;
                }
                else
                {
                    merge(stack[top - 2],stack[top - 1]);
                    stack[top - 1] = null;
                    --top;
                }
            }
            else if(top>=2 && (stack[top-2].size <= stack[top-1].size))
            {
                merge(stack[top - 2],stack[top - 1]);
                stack[top - 1] = null;
                --top;
            }
        }
        /*writeln("top = ", top);
        writeln("stack:");
        for(int i=0; i<top; ++i)
            writef("%3d ", stack[i].size);
        writeln();*/
    }
    /*writeln("top = ", top);
    writeln("stack:");
    for(int i=0; i<top; ++i)
        writef("%3d ", stack[i].size);
    writeln();*/
    while(top >= 2)
    {
        merge(stack[top - 2],stack[top - 1]);
        stack[top - 1] = null;
        --top;
    }

    list.beg = stack[top - 1].beg;
    list.end = stack[top - 1].end;
    list.size = stack[top - 1].size;
    stack[top - 1] = null;
    --top;
}






private void beisen(Type)(List!Type run, Node!Type* q, uint size, List!Type list) nothrow
{
    run.beg = list.beg;
    run.end = q;
    run.size = size;
    list.beg = q.right;
    list.size -= size;
    q.right = null;
    if(list.beg)
    {
        list.beg.left = null;
    }
    else
    {
        list.end = null;
    }
}

private void reverse(Type)(List!Type list)
{
    if(!list.isEmpty)
    {
        List!Type temp = new List!Type;
        while(!list.isEmpty)
        {
            temp.pushBack(list.popNodeBack());
        }
        list.beg=temp.beg;
        list.end=temp.end;
        temp=null;
    }
}
