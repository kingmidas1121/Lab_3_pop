with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;
with Ada.Containers.Indefinite_Doubly_Linked_Lists; use Ada.Containers;
with Ada.Numerics.Discrete_Random;
with Ada.Characters.Latin_1;
with Ada.Characters.Wide_Latin_1;


procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   type RandRange is range 1 .. 100;

   protected ItemsHandler is
      procedure SetProduction (Total : in Integer);
      procedure GetProduction (Result : out Boolean);
      procedure GetConsumption (Result : out Boolean);
      procedure DecrementProduced;
      procedure DecrementConsumed;
   private
      Left_Produced : Integer := 0;
      Left_Consumed : Integer := 0;
   end ItemsHandler;

   protected body ItemsHandler is
      procedure SetProduction (Total : in Integer) is
      begin
         Left_Produced := Total;
         Left_Consumed := Total;
      end SetProduction;

      procedure GetProduction (Result : out Boolean) is
      begin
         Result := Left_Produced = 0;
      end GetProduction;

      procedure GetConsumption (Result : out Boolean) is
      begin
          Result := Left_Consumed = 0;
      end GetConsumption;

      procedure DecrementProduced is
      begin
         if Left_Produced > 0 then
            Left_Produced := Left_Produced - 1;
         end if;
      end DecrementProduced;

      procedure DecrementConsumed is
      begin
         if Left_Consumed > 0 then
            Left_Consumed := Left_Consumed - 1;
         end if;
      end DecrementConsumed;

   end ItemsHandler;

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

   Storage_Size  : Integer := 3;
   Num_Producers : Integer := 4;
   Num_Consumers : Integer := 6;
   Total_Items   : Integer := 10;

   Storage        : List;
   Access_Storage : Counting_Semaphore (1, Default_Ceiling);
   Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
   Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

  task type Producer is
      entry Start (Num : Integer);
   end Producer;

   task body Producer is
      package Rand_Int is new Ada.Numerics.Discrete_Random (RandRange);
      use Rand_Int;
      Id   : Integer;
      Rand : Generator;
      Item : Integer;
   begin
      accept Start (Num : Integer) do
         Producer.Id := Num;
      end Start;
      Reset (Rand);
      while not IsProductionDone loop
         Full_Storage.Seize;
         Access_Storage.Seize;
         Item := Integer (Random (Rand));
         Storage.Append ("item" & Item'Img);
         Put_Line
           ("Producer #" & Id'Img & " adds item" & Item'Img);
         Access_Storage.Release;
         Empty_Storage.Release;
      end loop;
      Put_Line
        ("Producer #" & Id'Img & " finished working");
   end Producer;

   task type Consumer is
      entry Start (Num : Integer);
   end Consumer;
   task body Consumer is
      Id : Integer;
   begin
      accept Start (Num : Integer) do
         Consumer.Id := Num;
      end Start;
      while not IsConsumptionDone loop
         Empty_Storage.Seize;
         Access_Storage.Seize;
         declare
            Item : String := First_Element (Storage);
         begin
            Put_Line
              ("Consumer #" & Id'Img & " took " & Item );
            Storage.Delete_First;
            Access_Storage.Release;
            Full_Storage.Release;
         end;
      end loop;
      Put_Line
        ("Consumer #" & Id'Img & " finished working");
   end Consumer;

   type ProducerArr is array (Integer range <>) of Producer;
   type ConsumersArr is array (Integer range <>) of Consumer;

begin
   declare
      Producers : ProducerArr (1 .. Num_Producers);
      Consumers : ConsumersArr (1 .. Num_Consumers);
   begin
      ItemsHandler.SetProduction (Total => Total_Items);
      for I in 1 .. Num_Consumers loop
         Consumers (I).Start (I);
      end loop;

      for I in 1 .. Num_Producers loop
         Producers (I).Start (I);
      end loop;
   end;
end Main;
