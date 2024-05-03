with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;
with GNAT.Threads;


procedure Main is

   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;
  
   protected ItemsHandler is
  	procedure SetProduction (Total : in Integer);
  	procedure GetProduction (Result : out Boolean);
  	procedure GetConsumption (Result : out Boolean);
  	procedure DecrementProduced;
  	procedure DecrementConsumed;
   private
  	Remains_to_Produce : Integer := 0;
  	Remains_to_Consume : Integer := 0;
   end ItemsHandler;

   protected body ItemsHandler is
  	procedure SetProduction (Total : in Integer) is
  	begin
     	Remains_to_Produce := Total;
     	Remains_to_Consume := Total;
  	end SetProduction;

  	procedure GetProduction (Result : out Boolean) is
  	begin
     	Result := Remains_to_Produce = 0;
  	end GetProduction;

  	procedure GetConsumption (Result : out Boolean) is
  	begin
      	Result := Remains_to_Consume = 0;
  	end GetConsumption;

  	procedure DecrementProduced is
  	begin
     	if Remains_to_Produce > 0 then
        	Remains_to_Produce := Remains_to_Produce - 1;
     	end if;
  	end DecrementProduced;

  	procedure DecrementConsumed is
  	begin
     	if Remains_to_Consume > 0 then
        	Remains_to_Consume := Remains_to_Consume - 1;
     	end if;
  	end DecrementConsumed;

   end ItemsHandler;

   procedure Init (StorageSize : in Integer;
               	ProducersCount : in Integer; ConsumersCount : in Integer) is
  	Storage : List;
  	Access_Storage : Counting_Semaphore (1, Default_Ceiling);
  	Full_Storage   : Counting_Semaphore (StorageSize, Default_Ceiling);
  	Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);
  	
   function IsProductionDone return Boolean is
   begin
  	declare
     	Result : Boolean := False;
  	begin
     	ItemsHandler.GetProduction(Result);
     	ItemsHandler.DecrementProduced;
     	return Result;
  	end;
   end IsProductionDone;

   function IsConsumptionDone return Boolean is
   begin
  	declare
     	Result : Boolean := False;
  	begin
     	ItemsHandler.GetConsumption(Result);
     	ItemsHandler.DecrementConsumed;
     	return Result;
  	end;
   end IsConsumptionDone;

  	task type ProducerTask;
  	task body ProducerTask is
  	begin

     	while not IsProductionDone loop

        	Full_Storage.Seize;
        	Access_Storage.Seize;

        	Storage.Append ("item ");
        	Put_Line ("Producer add item");

        	Access_Storage.Release;
        	Empty_Storage.Release;

     	end loop;
  	end ProducerTask;


  	task type ConsumerTask;
  	task body ConsumerTask is
  	begin


     	while not IsConsumptionDone loop

        	Empty_Storage.Seize;
        	Access_Storage.Seize;

        	Put_Line ("Consumer took " & First_Element (Storage));
        	Storage.Delete_First;

        	Access_Storage.Release;
        	Full_Storage.Release;

     	end loop;
  	end ConsumerTask;

  	Consumers : Array(1..ConsumersCount) of ConsumerTask;
  	Producers : Array(1..ProducersCount) of ProducerTask;

   begin
  	null;
   end Init;

begin
   ItemsHandler.SetProduction(10);
   Init(3, 6, 4);
end Main;
