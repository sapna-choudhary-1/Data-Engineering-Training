class Car:
    """A class representing a car."""
    wheels = 4  # Shared by all instances

    def __init__(self, model, color, speed=0):
        self.model = model
        self.color = color
        self._speed = speed
        self.__engine_status = "off"

    @property
    def speed(self):
        return self._speed

    @speed.setter
    def speed(self, value):
        if value < 0:
            raise ValueError("Speed cannot be negative.")
        self._speed = value

    @property
    def engine_status(self):
        return self.__engine_status

    @engine_status.setter
    def engine_status(self, status):
        if status not in ["on", "off"]:
            raise ValueError("Engine status must be 'on' or 'off'.")
        self.__engine_status = status

    def toggle_engine(self):
        self.__engine_status = "on" if self.__engine_status == "off" else "off"
        print(f"{self.model} engine is now {self.__engine_status.upper()}.")

    def accelerate(self, increment):
        if increment < 0:
            raise ValueError("Increment must be non-negative.")
        self._speed += increment
        print(f"{self.model} accelerated to {self._speed} km/h")

    def decelerate(self, decrement):
        if decrement < 0:
            raise ValueError("Decrement must be non-negative.")
        if self._speed - decrement < 0:
            raise ValueError("Speed cannot be negative.")
        self._speed -= decrement
        print(f"{self.model} decelerated to {self._speed} km/h")

    def start(self):
        print(f"{self.model} is starting.")

    def stop(self):
        print(f"{self.model} is stopping.")

    @classmethod
    def get_wheels(cls):
        return cls.wheels

    @staticmethod
    def is_motorized():
        return True

    @staticmethod
    def vehicle_info():
        return "Cars are used for transportation."

    def __str__(self):
        return f"{self.color} {self.model} | Speed: {self._speed} km/h | Engine: {self.__engine_status}"

    def __repr__(self):
        return f"Car(model='{self.model}', color='{self.color}', speed={self._speed}, engine_status='{self.__engine_status}')"


class ElectricCar(Car):
    """Electric car extending Car class with battery info."""
    def __init__(self, model, color, battery_capacity, speed=0):
        super().__init__(model, color, speed)
        self.battery_capacity = battery_capacity

    def charge(self):
        print(f"{self.model} is charging. Battery: {self.battery_capacity} kWh")

    def __str__(self):
        base_str = super().__str__()
        return f"{base_str} | Battery: {self.battery_capacity} kWh"


# === Usage ===

if __name__ == "__main__":
    print("\n--- Basic Usage ---")
    car = Car("Toyota", "Red")
    car.start()
    car.accelerate(40)
    car.toggle_engine()
    car.decelerate(10)
    print(car)

    ec = ElectricCar("Tesla", "White", 75)
    ec.start()
    ec.accelerate(60)
    ec.charge()
    ec.toggle_engine()
    print(ec)

    print("\n--- Class and Instance Info ---")
    print(f"Car wheels: {Car.wheels}")
    print(f"car.wheels: {car.wheels}")
    print(f"electric_car.wheels: {ec.wheels}")

    print(f"Car model: {car.model}")
    print(f"Electric car model: {ec.model}")

    print(f"Car speed: {car.speed}")
    print(f"Electric car speed: {ec.speed}")

    print(f"Car engine status: {car.engine_status}")
    print(f"Electric car engine status: {ec.engine_status}")

    print(f"Electric car battery: {ec.battery_capacity} kWh")

    print("\n--- String Representations ---")
    print("str(car):", str(car))
    print("repr(car):", repr(car))
    print("str(electric_car):", str(ec))
    print("repr(electric_car):", repr(ec))

    print("\n--- Class & Static Methods ---")
    print(f"Car.get_wheels(): {Car.get_wheels()}")
    print(f"Car.is_motorized(): {Car.is_motorized()}")
    print(f"Car.vehicle_info(): {Car.vehicle_info()}")

    print("\n--- Method Overriding (Instance-level) ---")
    car.vehicle_info = lambda: "Custom vehicle info for this car."
    print(car.vehicle_info())
    ec.vehicle_info = lambda: "Custom vehicle info for this electric car."
    print(ec.vehicle_info())

    print("\n--- MRO & Base Classes ---")
    print("Car.__bases__:", Car.__bases__)
    print("Car.__mro__:", Car.__mro__)
    print("ElectricCar.__bases__:", ElectricCar.__bases__)
    print("ElectricCar.__mro__:", ElectricCar.__mro__)

    print("\n--- Dir Checks (only show subset) ---")
    print("Subset of Car dir():", [x for x in dir(Car)])
    print("\nSubset of Car dir():", [x for x in dir(Car) if not x.startswith('_')][:10])
    print("\nSubset of ElectricCar dir():", [x for x in dir(ElectricCar) if not x.startswith('_')])
    
    print("\n--- Type Checks ---")
    print("Is car an instance of Car?", isinstance(car, Car))
    print("Is car an instance of Object?", isinstance(car, object))
    print("Is electric_car an instance of Object?", isinstance(ec, object))
    print("Is electric_car an instance of ElectricCar?", isinstance(ec, ElectricCar))
    print("Is electric_car an instance of Car?", isinstance(ec, Car))
    print("Is car an instance of ElectricCar?", isinstance(car, ElectricCar))

    print("\nIs car a subclass of Car?", issubclass(Car, Car))
    print("Is Car a subclass of ElectricCar?", issubclass(Car, ElectricCar))
    print("Is Car a subclass of object?", issubclass(Car, object))

    print("\nIs ElectricCar a subclass of Car?", issubclass(ElectricCar, Car))
    print("Is ElectricCar a subclass of ElectricCar?", issubclass(ElectricCar, ElectricCar))
    print("Is ElectricCar a subclass of object?", issubclass(ElectricCar, object))

    print("\nIs object a subclass of Car?", issubclass(object, Car))
    print("Is object a subclass of object?", issubclass(object, object))