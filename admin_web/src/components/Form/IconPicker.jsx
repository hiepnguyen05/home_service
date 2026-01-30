import React from 'react';
import { ICON_LIST } from '../../constants/icons';

const IconPicker = ({ selectedIcon, onSelect }) => {
    return (
        <div className="border border-gray-300 rounded-lg p-3 bg-gray-50">
            <label className="block text-sm font-medium text-gray-700 mb-2">Chọn Icon</label>
            <div className="grid grid-cols-5 md:grid-cols-8 gap-2 max-h-40 overflow-y-auto p-1 scrollbar-thin">
                {ICON_LIST.map((item) => {
                    const IconComponent = item.component;
                    const isSelected = selectedIcon === item.name;

                    return (
                        <button
                            key={item.name}
                            type="button"
                            onClick={() => onSelect(item.name)}
                            className={`flex flex-col items-center justify-center p-2 rounded-lg transition-all duration-200 aspect-square group relative
                                ${isSelected
                                    ? 'bg-blue-100 border-2 border-blue-500 text-blue-700 shadow-sm'
                                    : 'bg-white border border-gray-200 hover:border-blue-300 hover:bg-blue-50 text-gray-600'
                                }`}
                            title={item.label}
                        >
                            <IconComponent size={24} />
                            {/* Tooltip on hover if needed, or just rely on title */}
                        </button>
                    );
                })}
            </div>
            {selectedIcon && (
                <div className="mt-2 text-xs text-gray-600 flex items-center gap-1">
                    <span>Đã chọn:</span>
                    <span className="font-mono font-bold bg-gray-200 px-1 rounded">{selectedIcon}</span>
                </div>
            )}
        </div>
    );
};

export default IconPicker;
