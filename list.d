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

    @property Type onBack()
    {
        if(!isEmpty)
            return end.datum;
        else throw new ListException;
    }

    @property Type onFront()
    {
        if(!isEmpty)
            return beg.datum;
        else throw new ListException;
    }

    @property bool isEmpty() nothrow
    {
        return !beg && !end;
    }
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
    }
}

private void split(Type)(List!Type list, List!Type part)
{
    bool direction=false;
    Node!Type* p=list.beg, q=list.end;
    int pSize=1,qSize=1;
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
        direction=!direction;
    }
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
        list.end.right=temp.beg;
        temp.beg.left=list.end;
        list.size+=temp.size;
        temp.beg=null;
        temp.end=null;
        temp.size=0;
    }
    if(!part.isEmpty)
    {
        list.end.right=part.beg;
        part.beg.left=list.end;
        list.size+=part.size;
        part.beg=null;
        part.end=null;
        part.size=0;
    }
}
