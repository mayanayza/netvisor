import type { Port } from '$lib/features/hosts/types/base';

export const uuidv4Sentinel: string = '00000000-0000-0000-0000-000000000000';

export const utcTimeZoneSentinel: string = '1970-01-01T00:00:00Z';

export function formatDuration(startTime: string, endTime?: string) {
	if (!startTime) return '';

	const start = new Date(startTime);
	const end = endTime ? new Date(endTime) : new Date();
	const durationMs = end.getTime() - start.getTime();

	const totalSeconds = Math.floor(durationMs / 1000);
	const hours = Math.floor(totalSeconds / 3600);
	const minutes = Math.floor((totalSeconds % 3600) / 60);
	const seconds = totalSeconds % 60;

	// Format with leading zeros
	const hh = hours.toString().padStart(2, '0');
	const mm = minutes.toString().padStart(2, '0');
	const ss = seconds.toString().padStart(2, '0');

	return `${hh}:${mm}:${ss}`;
}

export function formatTimestamp(timestamp: string): string {
	try {
		const date = new Date(timestamp);
		return date.toLocaleString('en-US', {
			year: 'numeric',
			month: 'short',
			day: 'numeric',
			hour: '2-digit',
			minute: '2-digit',
			second: '2-digit',
			hour12: false
		});
	} catch {
		return timestamp; // Fallback to raw string if parsing fails
	}
}

// Truncate ID for display (show first 8 characters + ellipsis if longer than 12)
export function formatId(id: string): string {
	if (id.length <= 12) {
		return id;
	}
	return `${id.substring(0, 8)}...`;
}
export function formatPort(port: Port): string {
	return `${port.number}${port.protocol == 'Tcp' ? '/tcp' : '/udp'}`;
}
