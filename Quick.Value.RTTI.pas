{ ***************************************************************************

  Copyright (c) 2016-2019 Kike P�rez

  Unit        : Quick.Value.RTTI
  Description : FlexValue Helper for RTTI
  Author      : Kike P�rez
  Version     : 1.0
  Created     : 06/05/2019
  Modified    : 30/08/2019

  This file is part of QuickLib: https://github.com/exilon/QuickLib

 ***************************************************************************

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

 *************************************************************************** }
unit Quick.Value.RTTI;

{$i QuickLib.inc}

interface

uses
  SysUtils,
  Rtti,
  Quick.Value;

type

  IValueTValue = interface
  ['{B109F5F2-32E5-4C4B-B83C-BF00BB69B2D0}']
    function GetValue : TValue;
    procedure SetValue(const Value : TValue);
    property Value : TValue read GetValue write SetValue;
  end;

  TValueTValue = class(TValueData,IValueTValue)
  strict private
    fData : TValue;
  private
    function GetValue : TValue;
    procedure SetValue(const Value : TValue);
  public
    constructor Create(const Value : TValue);
    property Value : TValue read GetValue write SetValue;
  end;


  TRTTIFlexValue = record helper for TFlexValue
  private
    function CastToTValue: TValue;
    procedure SetAsTValue(const Value: TValue);
  public
    property AsTValue : TValue read CastToTValue write SetAsTValue;
    function AsType<T : class> : T;
  end;

implementation

{ TRTTIFlexValue }

function TRTTIFlexValue.AsType<T>: T;
begin
  Result := T(AsObject);
end;

function TRTTIFlexValue.CastToTValue: TValue;
begin
  try
    case DataType of
      dtNull : Result := TValueExtended;
      dtBoolean : Result := AsBoolean;
      dtString : Result := AsString;
      {$IFDEF MSWINDOWS}
      dtAnsiString : Result := AsAnsiString;
      dtWideString : Result := AsWideString;
      {$ENDIF}
      dtInteger,
      dtInt64 : Result := AsInt64;
      {$IFNDEF FPC}
      dtVariant : Result := TValue.FromVariant(AsVariant);
      dtInterface : Result := TValue.FromVariant(AsInterface);
      {$ENDIF}
      dtObject : Result := AsObject;
      dtArray : Result := (Self.Data as IValueTValue).Value;
      else raise Exception.Create('DataType not supported');
    end;
  except
    on E : Exception do raise Exception.CreateFmt('TFlexValue conversion to TValue error: %s',[e.message]);
  end;
end;

procedure TRTTIFlexValue.SetAsTValue(const Value: TValue);
begin
  Clear;
  case Value.Kind of
    tkInteger,
    tkInt64 : AsInt64 := Value.AsInt64;
    tkFloat : AsExtended := Value.AsExtended;
    tkChar,
    {$IFNDEF FPC}
    tkString,
    tkUstring,
    {$ELSE}
    tkAstring,
    {$ENDIF}
    tkWideString,
    tkWideChar : AsString := Value.AsString;
    tkEnumeration,
    tkSet : AsInteger := Value.AsInteger;
    tkClass : AsObject := Value.AsObject;
    tkInterface : AsInterface := Value.AsInterface;
    {$IFNDEF FPC}
    tkArray,
    tkDynArray : Self.SetAsCustom(TValueTValue.Create(Value),TValueDataType.dtArray);
    else AsVariant := Value.AsVariant;
    {$ENDIF}
  end;
end;

{ TValueTValue }

constructor TValueTValue.Create(const Value: TValue);
begin
  fData := Value;
end;

function TValueTValue.GetValue: TValue;
begin
  Result := fData;
end;

procedure TValueTValue.SetValue(const Value: TValue);
begin
  fData := Value;
end;

end.
