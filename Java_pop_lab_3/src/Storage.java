import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Semaphore;

class Storage{
    public int size;
    public Semaphore access;
    public Semaphore empty;
    public Semaphore full;
    public List<String> buffer;
    public volatile int productsToProcessed;
    public volatile int workDoneProducer;
    public volatile int workDoneConsumer;
    private int lastIndex = 0;

    public Storage(int size, int productsToProcessed){
        this.size = size;
        this.access = new Semaphore(1);
        this.empty = new Semaphore(0);
        this.full = new Semaphore(size);
        this.productsToProcessed = productsToProcessed;
        this.workDoneProducer = 0;
        this.workDoneConsumer = 0;
        buffer = new ArrayList<>();
    }

    public int put(){
        buffer.add("item " + lastIndex);
        lastIndex++;
        return lastIndex - 1;
    }
}