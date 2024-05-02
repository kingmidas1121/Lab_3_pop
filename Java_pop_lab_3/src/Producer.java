class Producer extends WorkingThread{
    public Producer(int index, Storage storage){
        super(index, storage);
    }

    @Override
    public void run() {
        while (storage.itemsProduced.getAndDecrement() > 0){
            try {
                storage.full.acquire();
                storage.access.acquire();
                int itemIndex = storage.put();
                System.out.println("Producer " + index + " added " + (itemIndex));
                storage.access.release();
                storage.empty.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        System.out.println("........... "+ this.index + " producer was ended");

    }
}