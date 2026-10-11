from abc import ABC, abstractmethod
from typing import Optional

class SMSProvider(ABC):
    """
    Abstract base class for SMS providers.
    Implement this interface to add SMS functionality.
    """
    
    @abstractmethod
    async def send_sms(self, phone_number: str, message: str) -> bool:
        """
        Send an SMS message to the specified phone number.
        
        Args:
            phone_number: The recipient's phone number
            message: The message content
            
        Returns:
            bool: True if the SMS was sent successfully, False otherwise
        """
        pass
    
    @abstractmethod
    def is_configured(self) -> bool:
        """
        Check if the SMS provider is properly configured.
        
        Returns:
            bool: True if configured, False otherwise
        """
        pass


class NoOpSMSProvider(SMSProvider):
    """
    No-op implementation of SMS provider.
    Used when no SMS provider is configured.
    """
    
    async def send_sms(self, phone_number: str, message: str) -> bool:
        """
        Does not actually send SMS. Returns False to indicate not sent.
        """
        return False
    
    def is_configured(self) -> bool:
        """
        Always returns False as this is a no-op provider.
        """
        return False
