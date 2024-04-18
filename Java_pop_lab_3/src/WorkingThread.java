import java.util.Random;

abstract class WorkingThread extends Thread{
    protected Storage storage;
    protected final int index;

    public WorkingThread(int index, Storage storage){
        this.storage = storage;
        this.index = index;
    }

    @Override
    public abstract void run();
}
