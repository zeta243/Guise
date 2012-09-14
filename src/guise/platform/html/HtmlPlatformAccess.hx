package guise.platform.html;
import composure.core.ComposeItem;
import guise.controls.ControlLayers;
import guise.platform.AbsPlatformAccess;
import guise.platform.IPlatformAccess;
import guise.platform.types.TextAccessTypes;
import guise.platform.types.DisplayAccessTypes;
import guise.platform.types.CoreAccessTypes;
import guise.platform.types.DrawingAccessTypes;
import guise.platform.types.InteractionAccessTypes;
import cmtc.ds.hash.ObjectHash;
import guise.traits.tags.CoreTags;
import composure.utilTraits.Furnisher;
import guise.platform.nme.core.FrameTicker;

/**
 * ...
 * @author Tom Byrne
 */

 
class HtmlPlatformAccess extends AbsPlatformAccess<ContInfo, LayerInfo>
{
	public static function install(within:ComposeItem){
		within.addTrait(new NmePlatformAccess());
		within.addTrait(new Furnisher(StageTag,	[TType(StageSkin)]));
	}
	
	
	public function new() 
	{
		super(ContInfo.create, ContInfo.destroy, LayerInfo.create, LayerInfo.destroy);
		
		registerAccess(FrameTicker, [IFrameTicker], getFrameTicker, returnFrameTicker);
		registerLayerAccess(FrameTicker, [IFrameTicker], getFrameTicker, returnFrameTicker);
		
		registerAccess(LayerOrderAccess, [ILayerOrderAccess], getLayeringAccess, returnLayeringAccess);
		registerAccess(MouseInteractions, [IMouseInteractions], getMouseIntAccess, returnMouseIntAccess);
		registerAccess(MouseClickable, [IMouseClickable], getMouseClickAccess, returnMouseClickAccess);
		registerAccess(KeyboardAccess, [IKeyboardAccess], getKeyAccess, returnKeyAccess);
		
		registerLayerAccess(TextAccess, [ITextInputAccess, ITextOutputAccess], getTextAccess, returnTextAccess);
		registerLayerAccess(FocusableAccess, [IFocusableAccess], getFocusableAccess, returnFocusableAccess);
		registerLayerAccess(SizableDisplayAccess, [ISizableDisplayAccess], getSizableAccess, returnSizableAccess);
		registerLayerAccess(FilterableAccess, [IFilterableAccess], getFilterableAccess, returnFilterableAccess);
		registerLayerAccess(GraphicsAccess, [IGraphics, IBitmapGraphics], getGraphicsAccess, returnGraphicsAccess);
		registerLayerAccess(MouseInteractions, [IMouseInteractions], getMouseIntLayerAccess, returnMouseIntLayerAccess);
		registerLayerAccess(MouseClickable, [IMouseClickable], getMouseClickLayerAccess, returnMouseClickLayerAccess);
		registerLayerAccess(KeyboardAccess, [IKeyboardAccess], getKeyLayerAccess, returnKeyLayerAccess);
	}
	
	@inject({asc:true})
	public var stageSkin(default, set_stageSkin):StageSkin;
	private function set_stageSkin(value:StageSkin):StageSkin {
		stageSkin = value;
		if (_keyboardAccess != null && _keyboardAccess.interactiveObject==null)_keyboardAccess.interactiveObject = (stageSkin == null?null:stageSkin.stage);
		return value;
	}
	
	private function getFrameTicker(info:Dynamic):FrameTicker {
		if (_frameTicker == null)_frameTicker = new FrameTicker();
		return _frameTicker;
	}
	private function returnFrameTicker(info:Dynamic, access:FrameTicker):Void { }
	
	private function getKeyAccess(cont:ContInfo):KeyboardAccess {
		//return new KeyboardAccess(cont.container);
		if (_keyboardAccess == null)_keyboardAccess = new KeyboardAccess(stageSkin==null?null:stageSkin.stage);
		return _keyboardAccess;
	}
	private function returnKeyAccess(layer:ContInfo, access:KeyboardAccess):Void {
		//access.interactiveObject = null;
	}
	private function getKeyLayerAccess(layer:LayerInfo):KeyboardAccess {
		layer.createContainer();
		return new KeyboardAccess(layer.container);
	}
	private function returnKeyLayerAccess(layer:LayerInfo, access:KeyboardAccess):Void {
		access.interactiveObject = null;
	}
	
	private function getLayeringAccess(cont:ContInfo):LayerOrderAccess {
		return new LayerOrderAccess(cont.container);
	}
	private function returnLayeringAccess(cont:ContInfo, access:LayerOrderAccess):Void {
		access.container = null;
	}
	private function getTextAccess(layer:LayerInfo):TextAccess{
		layer.createTextField();
		return new TextAccess(layer.textField);
	}
	private function returnTextAccess(layer:LayerInfo, access:TextAccess):Void {
		if (layer.sizable != null) layer.sizable.removeDisplay(layer.textField);
		
		layer.textField = null;
		layer.assessDisplayObject();
	}
	private function getFocusableAccess(layer:LayerInfo):FocusableAccess{
		layer.createTextField();
		return new FocusableAccess(layer.textField);
	}
	private function returnFocusableAccess(layer:LayerInfo, access:FocusableAccess):Void {
		access.interactiveObject = null;
	}
	private function getSizableAccess(layer:LayerInfo):SizableDisplayAccess {
		var ret:SizableDisplayAccess = new SizableDisplayAccess();
		if (layer.textField!=null) ret.addDisplay(layer.textField);
		if (layer.container != null) ret.addDisplay(layer.container);
		layer.sizable = ret;
		return ret;
	}
	private function returnSizableAccess(layer:LayerInfo, access:SizableDisplayAccess):Void {
		if (layer.textField!=null) access.removeDisplay(layer.textField);
		if (layer.container!=null) access.removeDisplay(layer.container);
	}
	private function getFilterableAccess(layer:LayerInfo):FilterableAccess {
		layer.filterable = new FilterableAccess();
		layer.assessDisplayObject();
		return layer.filterable;
	}
	private function returnFilterableAccess(layer:LayerInfo, access:FilterableAccess):Void {
		access.displayObject = null;
		layer.filterable = null;
	}
	private function getGraphicsAccess(layer:LayerInfo):GraphicsAccess {
		layer.createContainer();
		var ret:GraphicsAccess = new GraphicsAccess();
		ret.graphics = layer.container.graphics;
		return ret;
	}
	private function returnGraphicsAccess(cont:LayerInfo, access:GraphicsAccess):Void {
		access.graphics = null;
	}
	private function getMouseIntAccess(cont:ContInfo):MouseInteractions {
		return new MouseInteractions(cont.container);
	}
	private function returnMouseIntAccess(layer:ContInfo, access:MouseInteractions):Void {
		access.interactiveObject = null;
	}
	private function getMouseIntLayerAccess(layer:LayerInfo):MouseInteractions {
		layer.createContainer();
		return new MouseInteractions(layer.container);
	}
	private function returnMouseIntLayerAccess(layer:LayerInfo, access:MouseInteractions):Void {
		access.interactiveObject = null;
	}
	private function getMouseClickAccess(cont:ContInfo):MouseClickable {
		return new MouseClickable(cont.container);
	}
	private function returnMouseClickAccess(layer:ContInfo, access:MouseClickable):Void {
		access.interactiveObject = null;
	}
	private function getMouseClickLayerAccess(layer:LayerInfo):MouseClickable {
		layer.createContainer();
		return new MouseClickable(layer.container);
	}
	private function returnMouseClickLayerAccess(layer:LayerInfo, access:MouseClickable):Void {
		access.interactiveObject = null;
	}
}
class ContInfo {
	// TODO:pooling
	public static function create(context:ComposeItem):ContInfo {
		return new ContInfo(context);
	}
	public static function destroy(contInfo:ContInfo):Void {
		contInfo.context = null;
	}
	
	
	
	public var container(default, null):Sprite;
	public var context(default, set_context):ComposeItem;
	private function set_context(value:ComposeItem):ComposeItem {
		if(context!=null)context.removeTrait(_contSkin);
		context = value;
		if (context != null) context.addTrait(_contSkin);
		return value;
	}
	
	private var _contSkin:ContainerSkin;
	
	public function new(context:ComposeItem){
		//super();
		
		_contSkin = new ContainerSkin();
		container = _contSkin.sprite;
		
		this.context = context;
	}
}
class LayerInfo{
	// TODO:pooling
	public static function create(contInfo:ContInfo, layerName:String):LayerInfo {
		return new LayerInfo(contInfo, layerName);
	}
	public static function destroy(layerInfo:LayerInfo):Void{
		layerInfo.contInfo = null;
	}
	
	
	
	public var contInfo(default, set_contInfo):ContInfo;
	private function set_contInfo(value:ContInfo):ContInfo {
		if (contInfo != null && displayObject!=null) {
			contInfo.container.removeChild(displayObject);
		}
		contInfo = value;
		if (contInfo != null && displayObject!=null) {
			contInfo.container.addChild(displayObject);
		}
		return value;
	}
	public var displayObject:DisplayObject;
	
	public var textField:TextField;
	public var container:Sprite;
	
	public var layerName:String;
	
	public var sizable:SizableDisplayAccess;
	public var filterable:FilterableAccess;
	
	public function new(contInfo:ContInfo, layerName:String) 
	{
		//super();
		this.contInfo = contInfo;
		this.layerName = layerName;
	}
	
	public function createTextField():Void {
		if (textField == null) {
			textField = new TextField();
			textField.name = layerName;
			
			if (sizable != null) sizable.addDisplay(textField);
			
			assessDisplayObject();
		}
	}
	
	public function createContainer():Void {
		if (container == null) {
			container = new Sprite();
			container.name = layerName;
			
			assessDisplayObject();
		}
	}
	public function assessDisplayObject():Void {
		var value:DisplayObject = (container != null?container:textField);
		
		if (displayObject != value) {
			if (displayObject != null && contInfo!=null) {
				contInfo.container.removeChild(displayObject);
			}
			displayObject = value;
			if (displayObject != null && contInfo!=null) {
				contInfo.container.addChild(displayObject);
				
				if (container != null) {
					if (textField!=null) {
						container.addChild(textField);
					}
				}
			}
		}
		if (filterable != null) {
			filterable.displayObject = value;
		}
	}
}
/*import guise.platform.nme.display.DisplaySkin;
class DisplaySkinSettable extends DisplaySkin {
	public function new(?displayObject:DisplayObject) {
		super(displayObject);
	}
	
	override public function setDisplayObject(displayObject:DisplayObject):Void {
		super.setDisplayObject(displayObject);
	}
	override private function assumeDisplayObject():Void {
		//ignore
	}
}*/