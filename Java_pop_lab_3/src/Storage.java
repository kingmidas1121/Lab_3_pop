import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

class Storage{
    public int size;
    public Semaphore access;
    public Semaphore empty;
    public Semaphore full;
    public List<String> buffer;
    public int productsToProcessed;
    private int lastIndex = 0;
    public AtomicInteger itemsProduced;
    public AtomicInteger itemsReceived;


    public Storage(int size, int productsToProcessed){
        this.size = size;
        this.access = new Semaphore(1);
        this.empty = new Semaphore(0);
        this.full = new Semaphore(size);
        this.productsToProcessed = productsToProcessed;
        this.itemsProduced = new AtomicInteger(productsToProcessed);
        this.itemsReceived = new AtomicInteger(productsToProcessed);
        buffer = new ArrayList<>();
    }

    public int put(){
        buffer.add("item " + lastIndex);
        lastIndex++;
        return lastIndex - 1;
    }
}