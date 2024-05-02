with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;
with GNAT.Threads;


procedure Main is

   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   WorkTarget : Integer := 10;
   ProducersCount : Integer := 3;
   ConsumersCount : Integer := 6;
   StorageSize  : Integer := 4;
   Storage : List;
   Access_Storage : Counting_Semaphore (1, Default_Ceiling);
   Full_Storage   : Counting_Semaphore (StorageSize, Default_Ceiling);
   Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);
   ProducersWorkDone : Integer := 0;
   ConsumersWorkDone : Integer := 0;


      task type ProducerTask;
      task body ProducerTask is
      begin

         while (ProducersWorkDone < WorkTarget) loop

            Full_Storage.Seize;
            Access_Storage.Seize;

         if ProducersWorkDone >= WorkTarget then
            Put_Line ("end of thread " & ProducersWorkDone'Img);
            Full_Storage.Release;
            Access_Storage.Release;
            Empty_Storage.Release;
            exit;
            end if;

            Storage.Append ("item " & ProducersWorkDone'Img);
            Put_Line ("Producer add item " & ProducersWorkDone'Img);
            ProducersWorkDone := ProducersWorkDone + 1;

            Access_Storage.Release;
            Empty_Storage.Release;

         end loop;
                Put_Line ("..........Producer was ended ");
      end ProducerTask;


      task type ConsumerTask;
      task body ConsumerTask is
      begin

         while (ConsumersWorkDone  < WorkTarget) loop

            Empty_Storage.Seize;
            Access_Storage.Seize;

            if ConsumersWorkDone >= WorkTarget then
            Full_Storage.Release;
            Access_Storage.Release;
            Empty_Storage.Release;

            exit;
            end if;
               Put_Line ("Consumer took " & First_Element (Storage));
            Storage.Delete_First;
            ConsumersWorkDone := ConsumersWorkDone + 1;

            Access_Storage.Release;
            Full_Storage.Release;

      end loop;
                  Put_Line ("..........Consumer was ended ");
      end ConsumerTask;

      Consumers : Array(1..ConsumersCount) of ConsumerTask;
      Producers : Array(1..ProducersCount) of ProducerTask;
begin
   null;
end Main;
