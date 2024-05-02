class Consumer extends WorkingThread{
    public Consumer(int index, Storage storage){
        super(index, storage);
    }

    @Override
    public void run() {
        while (storage.itemsReceived.getAndDecrement() > 0){
            try {
                storage.empty.acquire();
                storage.access.acquire();
                String item = storage.buffer.remove(0);
                System.out.println("Consumer " + index + " took " + (item));
                storage.access.release();
                storage.full.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        }
        System.out.println("........... "+ this.index + " consumer was ended");

    }
}