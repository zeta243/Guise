package guise.skin.drawn;
import guise.accessTypes.IPositionAccess;
import guise.accessTypes.IGraphicsAccess;
import guise.platform.cross.IAccessRequest;
import guise.platform.GraphicsApi;
import guise.skin.drawn.utils.DrawnStyles;
import guise.skin.drawn.utils.DrawnStyleUtils;
import guise.values.IValue;
import guise.skin.common.PositionedLayer;

class SimpleShapeLayer extends PositionedLayer<ShapeStyle>, implements IAccessRequest
{
	private static var ACCESS_TYPES:Array<Class<Dynamic>> = [IGraphicsAccess,IPositionAccess];
	
	@injectAdd
	private function onGraphicsAdd(access:IGraphicsAccess):Void {
		if (layerName != null && access.layerName != layerName) return;
		
		_graphicsAccess = access;
		if (_graphicsAccess != null) {
			_graphicsAccess.idealDepth = idealDepth;
		}
		invalidate();
	}
	@injectRemove
	private function onGraphicsRemove(access:IGraphicsAccess):Void {
		if (access != _graphicsAccess) return;
		
		_graphicsAccess = null;
	}
	
	@injectAdd
	private function onPosAdd(access:IPositionAccess):Void {
		if (layerName != null && access.layerName != layerName) return;
		
		_pos = access;
		invalidate();
	}
	@injectRemove
	private function onPosRemove(access:IPositionAccess):Void {
		if (access != _pos) return;
		
		_pos = null;
	}
	
	@:isVar public var idealDepth(default, set_idealDepth):Int;
	private function set_idealDepth(value:Int):Int {
		this.idealDepth = value;
		if (_graphicsAccess != null) {
			_graphicsAccess.idealDepth = idealDepth;
		}
		return value;
	}
	
	private var _graphicsAccess:IGraphicsAccess;
	private var _pos:IPositionAccess;
	

	public function new(?layerName:String, ?normalStyle:ShapeStyle) 
	{
		super(layerName, normalStyle);
	}
	public function getAccessTypes():Array<Class<Dynamic>> {
		return ACCESS_TYPES;
	}
	override private function _isReadyToDraw():Bool {
		return _graphicsAccess != null && _pos!=null && super._isReadyToDraw();
	}
	override private function _clearStyle():Void {
		_graphicsAccess.clear();
	}
	override private function _drawStyle():Void {
		_pos.setPos(x,y);
		
		_graphicsAccess.clear();
		
		var style:ShapeStyle = currentStyle;
		
		var draw:GraphArray<IGraphicsData> = new GraphArray<IGraphicsData>();
		removeValuesByHandler(onShapeValueChanged);
		drawShape(draw, currentStyle);
		draw.push(new GraphicsEndFill());
		
		_graphicsAccess.drawGraphicsData(draw);
	}
	private function drawShape(commands:GraphArray<IGraphicsData>, style:ShapeStyle):Void {
		
		switch(style) {
			case SsMulti(shapes):
				for (childShape in shapes) {
					drawShape(commands, childShape);
				}
			case SsEllipse(f, s, w, h, x, y):
				var xVal:Float = getValue(x, 0, onShapeValueChanged, false);
				var yVal:Float = getValue(y, 0, onShapeValueChanged, false);
				var wVal:Float = getValue(w, this.w, onShapeValueChanged, false);
				var hVal:Float = getValue(h, this.h, onShapeValueChanged, false);
				var path:GraphArray<IGraphicsData> = new GraphArray<IGraphicsData>();
				path.push(DrawnStyleUtils.drawEllipse(null, xVal, yVal, wVal, hVal));
				DrawnStyleUtils.beginFillStrokes(f, s, false, wVal, hVal, path, commands);
		}
	}
	private function onShapeValueChanged(?param1:Dynamic, ?param2:Dynamic):Void {
		invalidate();
	}
}
enum ShapeStyle {
	SsMulti(ShapeStyle:Array<ShapeStyle>);
	SsEllipse(f:FillStyle, s:StrokeStyle, ?w:IValue, ?h:IValue, ?x:IValue, ?y:IValue);
}