class Consumer extends WorkingThread{
    public Consumer(int index, Storage storage){
        super(index, storage);
    }

    @Override
    public void run() {
        while (storage.ConsumersWorkDone < storage.productsToProcessed){
            try {
                storage.empty.acquire();
                storage.access.acquire();

                if (storage.workDoneConsumer >= storage.productsToProcessed){
                    storage.empty.release();
                    storage.full.release();
                    storage.access.release();
                    System.out.println("........... "+ this.index + " consumer was ended");
                    return;
                }
                String item = storage.buffer.remove(0);
                System.out.println("Consumer " + index + " took " + (item));
                storage.workDoneConsumer++;

                storage.access.release();
                storage.full.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        }
        System.out.println("........... "+ this.index + " consumer was ended");

    }
}
