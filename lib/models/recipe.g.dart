// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 1;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as int,
      title: fields[1] as String,
      image: fields[2] as String,
      ingredients: (fields[3] as List).cast<String>(),
      instructions: (fields[4] as List).cast<String>(),
      readyInMinutes: fields[5] as int,
      servings: fields[6] as int,
      vegetarian: fields[7] as bool,
      vegan: fields[8] as bool,
      glutenFree: fields[9] as bool,
      dairyFree: fields[10] as bool,
      summary: fields[11] as String?,
      sourceUrl: fields[12] as String?,
      cuisines: (fields[13] as List).cast<String>(),
      dishTypes: (fields[14] as List).cast<String>(),
      spoonacularScore: fields[15] as double?,
      healthScore: fields[16] as int?,
      isFavorite: fields[17] as bool,
      savedDate: fields[18] as DateTime?,
      extendedIngredients: (fields[19] as List).cast<RecipeIngredient>(),
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.ingredients)
      ..writeByte(4)
      ..write(obj.instructions)
      ..writeByte(5)
      ..write(obj.readyInMinutes)
      ..writeByte(6)
      ..write(obj.servings)
      ..writeByte(7)
      ..write(obj.vegetarian)
      ..writeByte(8)
      ..write(obj.vegan)
      ..writeByte(9)
      ..write(obj.glutenFree)
      ..writeByte(10)
      ..write(obj.dairyFree)
      ..writeByte(11)
      ..write(obj.summary)
      ..writeByte(12)
      ..write(obj.sourceUrl)
      ..writeByte(13)
      ..write(obj.cuisines)
      ..writeByte(14)
      ..write(obj.dishTypes)
      ..writeByte(15)
      ..write(obj.spoonacularScore)
      ..writeByte(16)
      ..write(obj.healthScore)
      ..writeByte(17)
      ..write(obj.isFavorite)
      ..writeByte(18)
      ..write(obj.savedDate)
      ..writeByte(19)
      ..write(obj.extendedIngredients);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeIngredientAdapter extends TypeAdapter<RecipeIngredient> {
  @override
  final int typeId = 2;

  @override
  RecipeIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeIngredient(
      name: fields[0] as String,
      amount: fields[1] as double,
      unit: fields[2] as String,
      image: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeIngredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
