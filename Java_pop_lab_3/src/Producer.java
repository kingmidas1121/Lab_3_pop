class Producer extends WorkingThread{
    public Producer(int index, Storage storage){
        super(index, storage);
    }

    @Override
    public void run() {
        while (storage.workDoneProducer < storage.productsToProcessed){
            try {
                storage.full.acquire();
                storage.access.acquire();

                if (storage.workDoneProducer >= storage.productsToProcessed){
                    storage.full.release();
                    storage.access.release();
                    storage.empty.release();
                    System.out.println("........... "+ this.index + " producer was ended");
                    return;
                }

                int itemIndex = storage.put();
                System.out.println("Producer " + index + " added " + (itemIndex));
                storage.workDoneProducer++;

                storage.access.release();
                storage.empty.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        System.out.println("........... "+ this.index + " producer was ended");

    }
}